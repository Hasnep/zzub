import json
import argparse
from pathlib import Path
from typing import Dict, Any, List

parser = argparse.ArgumentParser()
parser.add_argument("output_file_path", type=Path)
parser.add_argument("--local", action="store_true", dest="is_local")
parser.add_argument("--server_ip", type=str)
args = parser.parse_args()
output_file_path: Path = args.output_file_path
is_local: bool = args.is_local
server_ip:str=args.server_ip

# def get_path_to_dockerfiles(is_local:bool)->Path:
#     if is_local:
#         return Path(".") / "docker"
#     else:
#         return Path("/home/zzub")/"docker"


def get_services(enabled_services: List[str]) -> Dict[str, Dict[str, Any]]:
    services = {
        "client": {
            "build": {
                "dockerfile": "./docker/client.dockerfile",
                "context": "..",
                "args": {
                    "SERVER_HOST": "localhost" if is_local else server_ip,
                    "SERVER_PORT": "5000" if is_local else "5001",
                },
            },
            "image": "zzub-client",
            "ports": ["80:80"],
            # "networks": ["cloud"],
            # "restart": "always",
            # "depends_on": [s for s in enabled_services if s != "nginx"],
        },
        "server": {
            "build": {"dockerfile": "./docker/server.dockerfile", "context": ".."},
            "image": "zzub-server",
            "ports": ["5001:5001"],
        },
    }
    return {k: v for k, v in services.items() if k in enabled_services}


enabled_services = ["client", "server"]

docker_compose = {
    "version": "3.9",
    "services": get_services(enabled_services),
    # "networks": {"cloud": {"driver": "bridge"}},
}

with open(output_file_path, "w") as f:
    f.write(json.dumps(docker_compose))
