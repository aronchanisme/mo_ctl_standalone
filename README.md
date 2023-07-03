# mo_ctl_standalone
mo_ctl tool is a tool designed to manage standalone matrixone server, such as deploying, starting, stopping, connect and much more administrations to your standalone matrixone server!

# How to get it
Depending on whether your machine has access to the Internet or not, choose one of the ways to get this tool.
```bash
# 1. install with the Internet
wget https://github.com/matrixorigin/mo_ctl_standalone/blob/main/install.sh && bash +x install.sh

# 2. install without the Internet
# 1) download them to your pc first, then upload them to your machine
wget https://github.com/matrixorigin/mo_ctl_standalone/blob/main/install.sh
wget https://github.com/matrixorigin/mo_ctl_standalone/archive/refs/heads/main.zip

# 2) install from offline pacakge
bash +x ./install.sh main.zip
```

# How to use it
After mo_ctl is installed, you can use `mo_ctl help` to print help info on how to use.