set project_root $HOME/Documents/godot/jackbox-test
cd $project_root
alias rsync='rsync --recursive --times --update --verbose --human-readable --compress --mkpath'

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
rsync --exclude-from=$project_root/server/.gitignore $project_root/server/ "root@$server_ip":/home/zzub/server/

# Build docker compose file
python3 docker/docker-compose.py --server_ip=$server_ip docker/docker-compose.yaml
# Upload docker files
rsync $project_root/docker/docker-compose.yaml "root@$server_ip":/home/zzub/docker/
rsync $project_root/docker/*.dockerfile "root@$server_ip":/home/zzub/docker/
rsync $project_root/scripts/nginx.conf "root@$server_ip":/home/zzub/docker/

ssh "root@$server_ip" 'bash /home/zzub/setup-scripts/0-setup-server.sh'
dirs -c

# Delete terraform infrastructure
linode-cli linodes delete (linode-cli linodes list --json | jq 'map(select(.label == "zzub"))[0].id')

# pushd $project_root
# scp -r $project_root/server/ "root@$server_ip:/home"
# cat $project_root/scripts/nginx.conf.template | sd --string-mode '{{server_ip}}' $server_ip >$project_root/scripts/nginx.conf
# ssh "root@$server_ip" "mkdir -p /etc/nginx/sites-enabled/"
# scp $project_root/scripts/nginx.conf "root@$server_ip:/etc/nginx/sites-enabled/jackbox-test-server"
# scp $project_root/scripts/setup-server.sh "root@$server_ip:/home/setup-server.sh"
# ssh "root@$server_ip" "source /home/setup-server.sh && cd /home/server && poetry run python -m jackbox_test_server"
# dirs -c


# ssh "root@$server_ip" 'mkdir -p /home/zzub/setup-scripts/'
# ssh "root@$server_ip" 'mkdir -p /home/zzub/docker-images/'
# rsync --recursive --times --update --verbose -h $project_root/docker/images/*.tar.gz "root@$server_ip":/home/zzub/docker-images/
# rsync$project_root/docker/images/*.tar.gz "root@$server_ip":/home/zzub/docker-images/

# # Build docker images
# pushd $project_root
# docker build --tag zzub-client -f docker/client.dockerfile .
# docker build --tag zzub-server -f docker/server.dockerfile .
# docker save zzub-client | pigz >docker/images/zzub-client.tar.gz
# docker save zzub-server | pigz >docker/images/zzub-server.tar.gz
# dirs -c


# # Build image
# pushd $project_root/packer
# # packer build -var linode_api_token=$linode_api_token .
# make
# set image_id (cat manifest.json | jq -r .builds[0].artifact_id) && echo $image_id
# dirs -c
