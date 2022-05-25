set project_root $HOME/Documents/godot/jackbox-test

black $project_root/docker/docker-compose.py \
    && pipx run nginxfmt $project_root/docker/nginx.conf \
    && python3 $project_root/docker/docker-compose.py $project_root/docker/docker-compose.yaml --local \
    && docker-compose -f $project_root/docker/docker-compose.yaml build --build-arg SERVER_HOST=localhost --build-arg SERVER_PORT=5001 \
    && docker-compose -f $project_root/docker/docker-compose.yaml up --remove-orphans
rip $project_root/docker/docker-compose.yaml
