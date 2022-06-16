set project_root $HOME/Documents/godot/jackbox-test
cd $project_root
alias rsync='rsync --recursive --times --update --verbose --human-readable --compress --mkpath'

# Build resources
source $project_root/scripts/build-resources.fish

# Deploy terraform infrastructure
pushd $project_root/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
dirs -c

# Get server IP
pushd $project_root/terraform
set server_ip (terraform output -raw server_ip)
echo $server_ip
dirs -c

# Setup the server
pushd $project_root

# Make sure we'll be able to ssh
ssh-keygen -f "/home/hannes/.ssh/known_hosts" -R $server_ip

# Install rsync on the server
ssh "root@$server_ip" 'sudo apt update && sudo apt install -y rsync'

# Send setup scripts
rsync $project_root/scripts/setup-scripts/ "root@$server_ip":/home/zzub/setup-scripts/

# Upload source code
rsync --exclude-from=$project_root/client/.gitignore $project_root/client/ "root@$server_ip":/home/zzub/client/
rsync $project_root/client/data/ "root@$server_ip":/home/zzub/client/data/
rsync $project_root/client/static/ "root@$server_ip":/home/zzub/client/static/
rsync --exclude-from=$project_root/server/.gitignore $project_root/server/ "root@$server_ip":/home/zzub/server/
rsync $project_root/server/data/ "root@$server_ip":/home/zzub/server/data/
rsync $project_root/server/static/ "root@$server_ip":/home/zzub/server/static/

# Build docker compose file
python3 docker/docker-compose.py --server_ip=$server_ip docker/docker-compose.yaml
# Upload docker files
rsync $project_root/docker/docker-compose.yaml "root@$server_ip":/home/zzub/docker/
rsync $project_root/docker/*.dockerfile "root@$server_ip":/home/zzub/docker/

ssh "root@$server_ip" 'bash /home/zzub/setup-scripts/0-setup-server.sh'
dirs -c

# Run the game
pushd $project_root/game
SERVER_HOST=$server_ip SERVER_PORT=5001 $HOME/bin/godot-4 --path $project_root/game
dirs -c

# Delete terraform infrastructure
linode-cli linodes delete (linode-cli linodes list --json | jq 'map(select(.label == "zzub"))[0].id')
