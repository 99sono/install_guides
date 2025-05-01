# Generate Self-Signed Certificate for ASUS Router

## 1. Understanding the Process

When setting up HTTPS access on your **local ASUS router**, we need to generate a certificate that browsers recognize as secure. Since we're not using an official **Certificate Authority (CA)**, we will **simulate** being our own CA by manually creating and signing a certificate.

This process consists of two key steps:

1. **Generate a Private Key** – This serves as the foundation for cryptographic security.
2. **Create and Sign a Self-Signed Certificate** – This allows HTTPS connections without browser warnings.

---

## 2. Generating Certificates

### **Step 1: Create the Private Key (Simulating a Certification Authority)**

Before issuing a certificate, we need to generate a private key that represents our **self-made CA**. This private key is used for signing the certificate.

Run the following command:

```bash
openssl genrsa -out my_ca_private.key 2048
```

#### **Explanation:**
- `openssl genrsa` – Generates an RSA private key.
- `-out my_ca_private.key` – Saves the key file with a meaningful name.
- `2048` – Specifies a **2048-bit key**, which is secure enough for most cases.

---

### **Step 2: Create and Sign the Self-Signed Certificate**

Once we have our private key, we use it to generate and sign our own SSL certificate:

```bash
openssl req -new -x509 -days 365 -key my_ca_private.key -out my_router_certificate.crt
```

#### **Explanation:**
- `openssl req -new -x509` – Creates a **certificate request** and immediately self-signs it.
- `-days 365` – Sets the certificate’s validity period (adjust as needed).
- `-key my_ca_private.key` – Uses our private key to sign the certificate.
- `-out my_router_certificate.crt` – Saves the signed certificate.

You'll be prompted to fill out details such as **Country Name, Common Name, Organization Name**, etc. The "Common Name" (CN) should match your **router’s domain or IP address** (e.g., `192.168.1.1`).

---

## 3. Installing the Certificate in Windows

### **Step 3: Import Certificate**
1. Double-click `my_router_certificate.crt`.
2. Click **"Install Certificate..."**.
3. Choose **"Local Computer"** and click Next.
4. Select **"Place all certificates in the following store"**.
5. Click **"Browse..."** and select **"Trusted Root Certification Authorities"**.
6. Complete the wizard.

### **Step 4: Verify Installation**
1. Open `certmgr.msc` (Windows Certificate Manager).
2. Navigate to **Trusted Root Certification Authorities > Certificates**.
3. Confirm that `my_router_certificate.crt` appears.

---

## 4. Installing the Certificate in WSL2 (Ubuntu)

### **Step 5: Copy and Update Certificates**
Run the following commands:

```bash
sudo cp my_router_certificate.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

### **Step 6: Verify Installation**
```bash
ls /etc/ssl/certs | grep my_router_certificate.crt
```

---

## 5. Configuring the ASUS Router

### **Step 7: Access Router Settings**
1. Open your browser and go to `https://192.168.1.1`.
2. Log in with your admin credentials.

### **Step 8: Install Certificate**
1. Navigate to **System > Certificate**.
2. Click **Import** and upload `my_router_certificate.crt`.
3. Set as the default certificate.

### **Step 9: Verify HTTPS Access**
1. Open browser and go to `https://192.168.1.1`.
2. Confirm that **no security warnings appear**.

---

## 6. Troubleshooting

### **Common Issues**
- **Certificate not trusted** → Ensure it's installed in the correct certificate store.
- **Expired certificate** → Renew using `openssl req -days <new_days> -x509`.
- **WSL2 issues** → Verify file paths and run `update-ca-certificates` after changes.

### **Verification Commands**
```bash
# Check certificate details
openssl x509 -in my_router_certificate.crt -text -noout

# Test HTTPS connection
curl -vk https://192.168.1.1
```



I'm really glad you liked it, Nuno! Here's an **Acknowledgements** section that you can easily copy and paste into your documentation:  


## Acknowledgements  

This guide was developed with valuable assistance from **Microsoft Copilot** and **QWEN 3:30B-A3B via Aider**.  

- **Microsoft Copilot** helped refine the documentation structure, ensuring clarity, precision, and alignment with best practices.  
- **QWEN 3:30B-A3B via Aider** provided deep analysis and reasoning to enhance the technical accuracy of the self-signed certificate setup process.  

Their combined contributions significantly improved this guide, making it more actionable and user-friendly.  
