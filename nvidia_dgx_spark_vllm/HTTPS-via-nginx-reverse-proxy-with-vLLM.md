# HTTPS via Nginx Reverse Proxy with vLLM (Self‑Signed Certificate)
Author: Deepseek-v4-flash

This guide sets up an Nginx reverse proxy to add HTTPS in front of an already running vLLM container.
The proxy handles SSL termination, request buffering (disabled for streaming), and security hardening.

Key features:

· Self‑signed certificate (clients must install it explicitly)
· No port exposure on vLLM – all traffic goes through Nginx
· Streaming support (proxy_buffering off)
· Blocks the vulnerable /invocations endpoint (CVE-2026-22778 mitigation)

---

Prerequisites

· A running vLLM container on a custom Docker network, without publishing its port to the host.
  Example vLLM start command (adjust model, API key, etc.):
  ```bash
  docker run -d --name vllm \
    --network my_network \
    vllm/vllm-openai:latest \
    --model meta-llama/Llama-2-7b-chat-hf \
    --api-key your-secret-key
  ```
  ⚠️ Do not add -p 8000:8000 – this would bypass the proxy.
· Docker and Docker Compose installed on the same host (the DGX machine).
· A domain name or IP address that clients will use (e.g., dgx.example.com or 10.0.0.5).

---

Step 1: Create Project Directory

```bash
mkdir nginx-proxy && cd nginx-proxy
```

---

Step 2: Generate Self‑Signed Certificate

Create a script to generate the certificate and private key:

```bash
# generate_cert.sh
#!/bin/bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx-selfsigned.key \
  -out nginx-selfsigned.crt \
  -subj "/CN=your-hostname-or-ip"
```

Make it executable and run:

```bash
chmod +x generate_cert.sh
./generate_cert.sh
```

Replace your-hostname-or-ip with the exact name/IP clients will use (e.g., dgx-01, 10.0.0.5). Mismatches cause certificate warnings.

---

Step 3: Create Nginx Configuration

Create nginx.conf:

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

Key points:

· server_name _ – matches any incoming Host header
· proxy_set_header Host $proxy_host – forwards the upstream name (vllm), avoiding host mismatch
· Streaming buffers are disabled globally inside http block

---

Step 4: Create Docker Compose File (Proxy Only)

Create docker-compose.yml:

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

The network my_network must already exist and both containers must be attached to it.
Create it if missing: docker network create my_network

---

Step 5: Start the Proxy

```bash
docker-compose up -d
```

Verify it's running:

```bash
docker-compose logs nginx
curl -k https://localhost/health   # Should reach vLLM's health endpoint
```

---

Step 6: Client‑Side Certificate Installation (Self‑Signed)

Every client that needs to access the vLLM API must trust your self‑signed certificate.

On Linux (Ubuntu/Debian)

```bash
# Copy the .crt file to the client machine
sudo cp nginx-selfsigned.crt /usr/local/share/ca-certificates/nginx.crt
sudo update-ca-certificates
```

On macOS

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain nginx-selfsigned.crt
```

On Windows

1. Double‑click the .crt file
2. Click Install Certificate
3. Choose Local Machine → Place all certificates in the following store → Trusted Root Certification Authorities
4. Finish

Python / requests

If you can’t install system‑wide, point to the cert file explicitly:

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

Security & Operational Notes

· vLLM API key – Ensure vLLM is started with --api-key. The proxy does not add authentication; clients must include the key in the Authorization header.
· .gitignore – If you version this directory, add .env and *.key to your .gitignore to avoid leaking secrets.
  ```
  # .gitignore
  .env
  *.key
  nginx-selfsigned.crt   # optional, but cert is not secret
  ```
· Firewall: Only expose port 443 (HTTPS) to clients. Block port 8000 (vLLM’s internal port) completely.
· Health check – The /health endpoint only confirms vLLM is running, not that a model is loaded. For production, implement a deeper readiness probe.

---

Appendix: Using Let’s Encrypt (free, trusted certificates)

Advantages over self‑signed

· Automatically trusted by all major browsers and operating systems – no manual installation on clients.
· Automatic renewal (Certbot).
· No security warnings.

Prerequisites

· A public domain name pointing to your DGX machine’s IP address.
· Port 80 (HTTP) reachable from the internet for the initial certificate challenge.

Example Certbot + Nginx Setup

1. Stop your self‑signed proxy (if running):
   ```bash
   docker-compose down
   ```
2. Run Certbot using the nginx image with a temporary config:
   ```bash
   docker run -it --rm -p 80:80 -p 443:443 \
     -v ./nginx-letsencrypt.conf:/etc/nginx/nginx.conf:ro \
     -v ./certbot-etc:/etc/letsencrypt \
     certbot/certbot certonly --standalone -d your-domain.com --email you@example.com --agree-tos
   ```
3. Update your nginx.conf to use the obtained certificate:
   ```nginx
   ssl_certificate     /etc/letsencrypt/live/your-domain.com/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
   ```
4. Mount the certs in docker-compose.yml:
   ```yaml
   volumes:
     - ./certbot-etc:/etc/letsencrypt:ro
   ```
5. Set up automatic renewal (cron or systemd timer) once a month.

Important: Let’s Encrypt requires a real domain

If you are on an internal network without a public domain, self‑signed remains the only practical option.

---

Troubleshooting

Symptom Likely cause Solution
502 Bad Gateway Nginx cannot reach vLLM Check that both containers are on the same Docker network and vLLM is running.
SSL errors (client side) Certificate not trusted Install the self‑signed cert on the client as shown in Step 6.
Streaming hangs Buffering re‑enabled Ensure proxy_buffering off; is present in the http block.
Host header mismatch vLLM expects a specific host Use proxy_set_header Host $proxy_host; (already in the config).

---


This guide gives you a secure, streaming‑ready HTTPS endpoint for vLLM using a self‑signed certificate. For production environments accessible via a public domain, migrate to Let’s Encrypt using the appendix.
