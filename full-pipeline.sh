

PREVIOUS_REVISION=${1}

cd /mnt/ripgrep-operator

bash vm-management.sh


cd ~/ripgrep-operator

bash rebuild-redeploy-new.sh ${PREVIOUS_REVISION}