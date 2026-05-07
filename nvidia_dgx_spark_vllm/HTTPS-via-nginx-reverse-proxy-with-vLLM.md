# HTTPS with vLLM via nginx Reverse Proxy (Docker Compose)

> ⚠️ **Disclaimer:** This guide is **untested and unverified**. It is provided for informational purposes only. Use at your own risk and validate all configurations in your environment before production deployment.

---

**Author:** Qwen 3.6 35B MoE (Mixture of Experts)

---

## Overview

This guide shows how to run your vLLM openAI-compatible API behind an nginx reverse proxy with a self-signed SSL certificate — all managed via Docker Compose. The certificate is also installed into the Ubuntu CA trust store so the OS and browsers won't complain.

---

## Prerequisites

- DGX Spark (ARM64) running Ubuntu
- Docker & Docker Compose installed
- vLLM container running on localhost:8000 (see existing `vllm/qwen-3.6-35b-a3b-vllm-nvpf4-dgx-spark/`)

---

## Step 1 — Create the nginx reverse-proxy stack

Create a new directory for the proxy configuration:

```bash
mkdir -p nginx-proxy/ssl
```

### docker-compose.yml

```yaml
version: "3.9"

services:
  nginx:
    image: nginx:1.30-alpine
    container_name: vllm-nginx-proxy
    platform: linux/arm64/v8
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl/cert.pem:/etc/nginx/ssl/cert.pem:ro
      - ./ssl/private.key:/etc/nginx/ssl/private.key:ro
    depends_on:
      - vllm
    restart: unless-stopped
    networks:
      - development-network

  vllm:
    container_name: qwen3-6-moe-35b-a3b-nvfp4
    # This references your existing vLLM container running on the development-network.
    # The vLLM container should already be running with its full configuration
    # (see your bare vLLM docker-compose for the full command definition).
    # No ports exposed here — nginx forwards all traffic.
    networks:
      - development-network

networks:
  development-network:
    external: true
```

### nginx.conf

```nginx
daemon off;
worker_processes auto;
error_log /dev/stderr warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
    access_log /dev/stdout main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    server {

        # ---- TLS ----
        listen 443 ssl;
        server_name localhost;

        ssl_certificate      /etc/nginx/ssl/cert.pem;
        ssl_certificate_key  /etc/nginx/ssl/private.key;
        ssl_protocols        TLSv1.2 TLSv1.3;
        ssl_ciphers          HIGH:!aNULL:!MD5;

        # Timeouts — vLLM long-running requests need generous values
        proxy_connect_timeout 300s;
        proxy_send_timeout    300s;
        proxy_read_timeout    300s;

        # Large request bodies for big prompts
        client_max_body_size 64m;
        proxy_body_size 64m;

        # Block unauthenticated /invocations endpoint (CVE-2026-22778)
        location /invocations {
            return 403 '{"error": "Access denied"}';
            add_header Content-Type application/json;
        }

        # Allow /v1 and /models routes only
        location ~ ^/(v1|models) {
            proxy_pass http://vllm:8000;

            # Forward client info
            proxy_set_header Host           $host;
            proxy_set_header X-Real-IP      $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Streaming / SSE for token-by-token output
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Upgrade    $http_upgrade;

            # Disable request buffering for large prompt uploads
            proxy_request_buffering off;

            # Chunked response passthrough for streaming
            proxy_buffering off;
            proxy_cache off;
        }

        # Health-check endpoint
        location /health {
            proxy_pass http://vllm:8000/health;
        }

        # Deny everything else
        location / {
            return 404 '{"error": "Not found"}';
        }
    }

    # Redirect HTTP → HTTPS
    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Generate the self-signed certificate

> **Note:** Replace `[DGX_IP]` with your DGX Spark's actual static IP address (e.g., `10.0.0.50`). This placeholder must be substituted before running the command.

Run this **once** at the project root:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx-proxy/ssl/private.key \
  -out nginx-proxy/ssl/cert.pem \
  -subj "/C=US/ST=California/L=Santa Clara/O=NVIDIA Spark/CN=localhost" \
  -addext "subjectAltName = DNS:localhost, IP:127.0.0.1, IP:[DGX_IP]"
```

> **Why `ca.crt` is not generated:** In a self-signed setup, `cert.pem` acts as both the server certificate and the CA certificate. The `ca.crt` file is not needed — nginx only requires `ssl_certificate` (cert.pem) and `ssl_certificate_key` (private.key) to establish HTTPS.

This produces:
- `nginx-proxy/ssl/cert.pem` — the public certificate
- `nginx-proxy/ssl/private.key` — the private key

### Install the cert in Ubuntu's CA trust store

Also once, at the project root:

```bash
sudo cp nginx-proxy/ssl/cert.pem /usr/local/share/ca-certificates/vllm-selfsigned.crt
sudo update-ca-certificates
```

After this, Ubuntu (and browsers) trust `https://localhost:443` without warnings.

---

## .env file

Copy the `.env.example` from your vLLM directory and add the `VLLM_API_KEY`:

```bash
cp vllm/qwen-3.6-35b-a3b-vllm-nvpf4-dgx-spark/.env.example .env
```

Then edit `.env` and set a real API key (or keep `dummy-key`).

---

## Step 2 — Run everything

> **Architecture note:** This guide adds an nginx reverse-proxy layer on top of your **existing bare vLLM container**. Your DGX Spark already runs vLLM directly on port 8000 (HTTP). The docker-compose.yml below replaces that direct port exposure — the nginx proxy now handles all external HTTPS traffic and forwards internal HTTP requests to the vLLM container on the shared Docker network.

From the **project root**:

```bash
docker compose --project-name vllm-https up -d --wait
```

This starts both the vLLM container and the nginx reverse proxy container on the same Docker network.

---

## Step 3 — Verify

```bash
# Check both containers are running
docker compose ps

# Check nginx is listening on 443 (uses -k to bypass untrusted cert until CA install)
curl -k https://localhost:443/v1/models

# Trust the cert (after update-ca-certificates) — no -k needed
curl https://localhost/v1/models
```

### Troubleshooting: Certificate verification

If `curl` still complains about the certificate immediately after `update-ca-certificates`:

```bash
# Option A: Verify the pipe works with explicit CA cert
curl --cacert nginx-proxy/ssl/cert.pem https://localhost/v1/models

# Option B: Restart your terminal session to pick up the updated CA trust store
```

The `--cacert` flag is useful to confirm the TLS handshake works before relying on the OS trust store.

### Troubleshooting: Route 404 errors

If you get `404 Not found` when hitting the API, ensure you're using the correct path. The nginx config only allows:

| Allowed Route  | Description                  |
|---------------|------------------------------|
| `/v1/...`     | OpenAI-compatible API        |
| `/models`     | Model listing                |
| `/health`     | Health check                 |
| `/invocations` | **Blocked** (403 Forbidden)  |

Any other path (e.g., `/v1/chat/completions` works under `/v1/`, but `/chat/completions` does not) will return a 404.

### Test a chat completion

```bash
curl -s https://localhost/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${VLLM_API_KEY:-dummy-key}" \
  -d '{
    "model": "Qwen3.6-35B-A3B-NVFP4",
    "messages": [{"role": "user", "content": "Say hello in one sentence."}]
  }'
```

---

## Step 4 — Stop everything

```bash
docker compose --project-name vllm-https down
```

---

## Directory structure

```
DockerBuildFiles/
├── .env
├── docker-compose.yml          # nginx + vLLM composite
├── nginx.conf
├── nginx-proxy/
│   ├── ssl/
│   │   ├── cert.pem
│   │   └── private.key
│   └── README.md
└── vllm/
    └── qwen-3.6-35b-a3b-vllm-nvpf4-dgx-spark/
        └── (original files, untouched)
```

---

## Key differences from bare vLLM

| Aspect          | Bare vLLM                  | With nginx reverse proxy        |
|-----------------|---------------------------|---------------------------------|
| Port            | `8000` (HTTP)             | `443` (HTTPS)                   |
| Certificate     | None                      | Self-signed (or ACME/Let's Encrypt) |
| Client trust    | Always needs `-k`         | Trusts after CA install         |
| Streaming       | Works                     | Works (`proxy_buffering off`)   |
| URL             | `http://localhost:8000`   | `https://localhost`             |

## Optional: get a real certificate

Replace the self-signed cert with a Let's Encrypt cert using the nginx-proxy docker image `nginx/nginx:latest` + [`nginx-letsencrypt`](https://github.com/directust/nginx-letsencrypt) or [`linuxserver/swag`](https://github.com/linuxserver/docker-swag). The nginx.conf structure remains nearly identical — just mount the certificate files instead of generating them locally.
