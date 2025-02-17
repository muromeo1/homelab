# Homelab

This repo keeps the architecture and the information of my own homelab.

## Description

![image](https://github.com/user-attachments/assets/aa0b8be5-3fa5-4024-9e0b-fab78de5579a)


My "cluster" specs:
- Asus VivoBook - X512JP
- Intel(R) Core(TM) i7-1065G - 8vCPU - 4 cores | 8 threads
- 16GB DDR5
- 512GB SSD NVMe

## K8S

Since I have a single machine, I decided to use [Proxmox](https://www.proxmox.com/en/) to virtualize it, so then I can split into multiple VM's that I can delete and setup anytime.

With that, I have 2 [talos](https://www.talos.dev/) nodes in my cluster:
- 1 control plane node
- 1 worker node

To expose my apps, I use [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) pointed to the NodePort of my application, with that, I can replicate my apps and still use tunneling to expose it.

Currently, I'm running:
- 🔒 [Vault](https://vault.casaos-31.com/#/login)
- 🏠 [Homeassistant](https://homeassistant.casaos-31.com/)
