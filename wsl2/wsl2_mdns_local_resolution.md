# WSL2 Local Network Device Discovery (mDNS)

## The Problem

When using WSL2 in the default NAT mode, the Linux environment often cannot resolve local hostnames (e.g., `<node-name>.local`) that are otherwise reachable via Windows PowerShell. This prevents seamless SSH or API access to local hardware such as DGX stations, Spark nodes, or Jetson devices using their network names.

## The Solution: mDNS Bridging

To allow WSL2 to "see" hostnames on your local physical network, you need to enable the **Multicast DNS (mDNS)** protocol. This is handled by the **Avahi** service, which bridges the discovery gap between WSL2 and the host network.

### 1. Installation

Install the Avahi daemon and the mDNS resolver library:

```bash
sudo apt update && sudo apt install avahi-utils libnss-mdns
```

### 2. How it Works

- **`avahi-daemon`** — Runs as a background service to handle network discovery.
- **`libnss-mdns`** — Updates the Linux "Name Service Switch" (`/etc/nsswitch.conf`) so that any query ending in `.local` is routed through the mDNS protocol instead of traditional DNS.

By default, WSL2 is "deaf" to mDNS broadcasts because it lives in its own containerized bubble. With Avahi installed, you effectively bridge this discovery gap, allowing your virtualized Linux environment to perceive hardware on your physical LAN just as clearly as Windows does natively.

#### Verification Step

After installation, verify that `libnss-mdns` is properly configured. Check that `/etc/nsswitch.conf` contains the following `hosts:` line:

```bash
grep '^hosts:' /etc/nsswitch.conf
```

The output should include `mdns4_minimal`:

```
hosts:          files mdns4_minimal [NOTFOUND=return] dns
```

This ensures the system actually calls the mDNS resolver when querying for `.local` hostnames.

### 3. Usage

Once installed, you no longer need to track changing DHCP IP addresses. You can reach your local devices directly:

```bash
# Replace <node-name> with your specific device hostname
ping <node-name>.local

ssh user@<node-name>.local
```

## Why `.local`?

The `.local` top-level domain is reserved for **Zero-Configuration Networking (mDNS)**. When you use this suffix, your computer sends a "multicast" packet to every device on the local network asking, *"Who is `<node-name>`?"*. The target device hears this and replies with its current IP address.

In contrast, a regular hostname like `google.com` is resolved by asking a **central DNS server** (such as your router or 8.8.8.8). Home lab devices are typically not registered in a central DNS registry — they announce themselves locally via mDNS. The `.local` suffix tells the operating system: *"Don't ask the central DNS server; instead, shout this name out loud to everyone on the local network and see if anyone claims it."*

## Troubleshooting

### Service Check

Ensure the Avahi daemon is running. Check its status with:

```bash
sudo service avahi-daemon status
```

If the service is not running, start it:

```bash
sudo service avahi-daemon start
```

### Firewall Note

Windows Firewall may occasionally block **UDP port 5353** (the mDNS port) on the WSL virtual network interface. If hostnames are still not resolving, verify that inbound/outbound rules for UDP 5353 are allowed on the WSL adapter in your Windows Firewall settings.

## Summary of Benefits

- **Dynamic IP Handling** — Works even if your router assigns a new IP to your hardware via DHCP.
- **No Windows Configuration Needed** — Fixes the issue entirely within the WSL2 environment.
- **Parity with Host** — Gives WSL2 the same network visibility that Windows enjoys natively on the local network.