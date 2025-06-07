# Powershell - Windows Users


# 1. Open Powershell as Administrator



# 2. Run your docker deamon (start Docker Desktop)


# 3. Select Driver for multipass (docker, virtualbox, hyper-v)

# multipass set local.driver=docker
# multipass set local.driver=virtualbox

# multipass get local.driver


multipass launch --name charm-dev --memory 4G --disk 10G --cloud-init environments/multipass/cloud-init.yaml
