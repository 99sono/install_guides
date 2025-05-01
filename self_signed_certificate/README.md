# Generate Self-Signed Certificate for ASUS Router

## 1. Generate Certificates

### 1.1 Create Private Key and Certificate
Run the following commands in your terminal:
```bash
openssl genrsa -out private.key 2048
openssl req -new -x509 -days 365 -key private.key -out certificate.pem
```

**Parameters to customize:**
- `private.key` - Your private key file
- `certificate.pem` - Your self-signed certificate file
- `-days 365` - Certificate validity period (adjust as needed)

## 2. Install Certificate in Windows

### 2.1 Import Certificate
1. Double-click `certificate.pem`
2. Click "Install Certificate..."
3. Choose "Local Computer" and click Next
4. Select "Place all certificates in the following store"
5. Click "Browse..." and select "Trusted Root Certification Authorities"
6. Complete the wizard

### 2.2 Verify Installation
1. Open `certmgr.msc`
2. Navigate to `Trusted Root Certification Authorities > Certificates`
3. Confirm your certificate appears

## 3. Install Certificate in WSL2 (Ubuntu)

### 3.1 Prepare Certificate
```bash
sudo cp certificate.pem /usr/local/share/ca-certificates/
sudo mv /usr/local/share/ca-certificates/certificate.pem /usr/local/share/ca-certificates/certificate.crt
sudo update-ca-certificates
```

### 3.2 Verify Installation
```bash
ls /etc/ssl/certs | grep certificate.crt
```

## 4. Configure ASUS Router

### 4.1 Access Router Settings
1. Open browser and go to `https://192.168.1.1`
2. Log in with your admin credentials

### 4.2 Install Certificate
1. Navigate to **System > Certificate**
2. Click **Import** and select your `certificate.pem` file
3. Set as default certificate

### 4.3 Verify HTTPS Access
1. Open browser and go to `https://192.168.1.1`
2. Confirm no security warnings appear

## Troubleshooting

### Common Issues
- **Certificate not trusted**: Ensure it's installed in the correct store
- **Expired certificate**: Renew with `openssl req -days <new_days> -x509`
- **WSL2 issues**: Verify file paths and run `update-ca-certificates` after changes

### Verification Commands
```bash
# Check certificate details
openssl x509 -in certificate.pem -text -noout

# Test HTTPS connection
curl -vk https://192.168.1.1
```
