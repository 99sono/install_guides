# 1. HTTPS via Nginx Reverse Proxy with vLLM (Self-Signed Certificate)

**Author:** Deepseek-v4-flash

This guide sets up an Nginx reverse proxy to add HTTPS in front of an already running vLLM container. The proxy handles SSL termination, request buffering (disabled for streaming), and security hardening.

## 1.1 Key Features

1. Self-signed certificate (clients must install it explicitly)
2. No port exposure on vLLM – all traffic goes through Nginx
3. Streaming support (`proxy_buffering off`)
4. Blocks the vulnerable `/invocations` endpoint (CVE-2026-22778 mitigation)

---

## 2. Prerequisites

1. A running vLLM container on a custom Docker network, without publishing its port to the host.

   Example vLLM start command (adjust model, API key, etc.):

   ```bash
   docker run -d --name vllm \
     --network my_network \
     vllm/vllm-openai:latest \
     --model meta-llama/Llama-2-7b-chat-hf \
     --api-key your-secret-key
   ```

   > ⚠️ **Do not** add `-p 8000:8000` – this would bypass the proxy.

2. Docker and Docker Compose installed on the same host (the DGX machine).
3. A domain name or IP address that clients will use (e.g., `dgx.example.com` or `10.0.0.5`).

---

## 3. Step 1: Create Project Directory

```bash
mkdir nginx-proxy && cd nginx-proxy
```

---

## 4. Step 2: Generate Self-Signed Certificate

### 4.1 Create the Certificate Script

Create a script to generate the certificate and private key:

```bash
# generate_cert.sh
#!/bin/bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx-selfsigned.key \
  -out nginx-selfsigned.crt \
  -subj "/CN=your-hostname-or-ip"
```

### 4.2 Make It Executable and Run

```bash
chmod +x generate_cert.sh
./generate_cert.sh
```

> 💡 **Tip:** Replace `your-hostname-or-ip` with the exact name/IP clients will use (e.g., `dgx-01`, `10.0.0.5`). Mismatches cause certificate warnings.

---

## 5. Step 3: Create Nginx Configuration

### 5.1 Create nginx.conf

```nginx
events {
    worker_connections 1024;
}

http {
    # Disable request/response buffering for streaming
    proxy_buffering off;
    proxy_request_buffering off;

    server {
        listen 443 ssl;
        server_name _;  # Accept any hostname (use _ or your IP/domain)

        ssl_certificate     /etc/nginx/ssl/nginx-selfsigned.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

        # Security hardening (optional)
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Block the vulnerable /invocations endpoint
        location = /invocations {
            return 403;
        }

        # Proxy everything else to vLLM
        location / {
            proxy_pass http://vllm:8000;
            proxy_set_header Host $proxy_host;   # Send internal container name
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 5.2 Key Configuration Points

1. **`server_name _`** – matches any incoming Host header
2. **`proxy_set_header Host $proxy_host`** – forwards the upstream name (`vllm`), avoiding host mismatch
3. **Streaming buffers** are disabled globally inside the `http` block

---

## 6. Step 4: Create Docker Compose File (Proxy Only)

### 6.1 Create docker-compose.yml

```yaml
services:
  nginx:
    image: nginx:latest
    container_name: nginx-proxy
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx-selfsigned.crt:/etc/nginx/ssl/nginx-selfsigned.crt:ro
      - ./nginx-selfsigned.key:/etc/nginx/ssl/nginx-selfsigned.key:ro
    networks:
      - my_network   # Must match the network your vLLM container uses

networks:
  my_network:
    external: true
```

> 💡 The network `my_network` must already exist and both containers must be attached to it. Create it if missing: `docker network create my_network`

---

## 7. Step 5: Start the Proxy

```bash
docker-compose up -d
```

### 7.1 Verify It's Running

```bash
docker-compose logs nginx
curl -k https://localhost/health   # Should reach vLLM's health endpoint
```

---

## 8. Step 6: Client-Side Certificate Installation (Self-Signed)

Every client that needs to access the vLLM API must trust your self-signed certificate.

### 8.1 On Linux (Ubuntu/Debian)

```bash
# Copy the .crt file to the client machine
sudo cp nginx-selfsigned.crt /usr/local/share/ca-certificates/nginx.crt
sudo update-ca-certificates
```

### 8.2 On macOS

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain nginx-selfsigned.crt
```

### 8.3 On Windows

1. Double-click the `.crt` file
2. Click **Install Certificate**
3. Choose **Local Machine** → Place all certificates in the following store → **Trusted Root Certification Authorities**
4. Click **Finish**

### 8.4 Python / requests

If you can't install system-wide, point to the cert file explicitly:

```python
import requests

response = requests.post(
    "https://your-host/v1/completions",
    headers={"Authorization": "Bearer your-api-key"},
    json={"prompt": "Hello", "max_tokens": 10},
    verify="/path/to/nginx-selfsigned.crt"
)
```

---

## 9. Security & Operational Notes

1. **vLLM API key** – Ensure vLLM is started with `--api-key`. The proxy does not add authentication; clients must include the key in the `Authorization` header.

2. **.gitignore** – If you version this directory, add `.env` and `*.key` to your `.gitignore` to avoid leaking secrets.

   ```
   # .gitignore
   .env
   *.key
   nginx-selfsigned.crt   # optional, but cert is not secret
   ```

3. **Firewall** – Only expose port 443 (HTTPS) to clients. Block port 8000 (vLLM's internal port) completely.

4. **Health check** – The `/health` endpoint only confirms vLLM is running, not that a model is loaded. For production, implement a deeper readiness probe.

---

## 10. Appendix: Using Let's Encrypt (Free, Trusted Certificates)

### 10.1 Advantages Over Self-Signed

1. Automatically trusted by all major browsers and operating systems – no manual installation on clients.
2. Automatic renewal (Certbot).
3. No security warnings.

### 10.2 Prerequisites

1. A public domain name pointing to your DGX machine's IP address.
2. Port 80 (HTTP) reachable from the internet for the initial certificate challenge.

### 10.3 Example Certbot + Nginx Setup

1. **Stop your self-signed proxy** (if running):

   ```bash
   docker-compose down
   ```

2. **Run Certbot** using the nginx image with a temporary config:

   ```bash
   docker run -it --rm -p 80:80 -p 443:443 \
     -v ./nginx-letsencrypt.conf:/etc/nginx/nginx.conf:ro \
     -v ./certbot-etc:/etc/letsencrypt \
     certbot/certbot certonly --standalone -d your-domain.com --email you@example.com --agree-tos
   ```

3. **Update your nginx.conf** to use the obtained certificate:

   ```nginx
   ssl_certificate     /etc/letsencrypt/live/your-domain.com/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
   ```

4. **Mount the certs** in `docker-compose.yml`:

   ```yaml
   volumes:
     - ./certbot-etc:/etc/letsencrypt:ro
   ```

5. **Set up automatic renewal** (cron or systemd timer) once a month.

> ⚠️ **Important:** Let's Encrypt requires a real domain. If you are on an internal network without a public domain, self-signed remains the only practical option.

---

## 11. Troubleshooting

| #  | Symptom                  | Likely Cause                        | Solution                                                                  |
|----|--------------------------|-------------------------------------|---------------------------------------------------------------------------|
| 1  | 502 Bad Gateway          | Nginx cannot reach vLLM             | Check that both containers are on the same Docker network and vLLM is running. |
| 2  | SSL errors (client side) | Certificate not trusted             | Install the self-signed cert on the client as shown in Step 8.            |
| 3  | Streaming hangs          | Buffering re-enabled                | Ensure `proxy_buffering off;` is present in the `http` block.             |
| 4  | Host header mismatch     | vLLM expects a specific host        | Use `proxy_set_header Host $proxy_host;` (already in the config).         |

---

## 12. Summary

This guide gives you a secure, streaming-ready HTTPS endpoint for vLLM using a self-signed certificate. For production environments accessible via a public domain, migrate to Let's Encrypt using the appendix in Section 10.