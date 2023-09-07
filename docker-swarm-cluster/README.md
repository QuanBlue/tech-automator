<h1 align="center">
  <img src="../assets/logo/docker-swarm-cluster-logo.png" alt="icon" width="200"></img>
  <br>
  <b>Docker Swarm Cluster Automator</b>
</h1>

<p align="center">Automatically create Docker Swarm cluster Docker CLI</p>
<br>

<details open>
<summary><b>Table of Contents</b></summary>

- [Getting Started](#toolbox-getting-started)
  - [Prerequisites](#prerequisites)
  - [Environment Variables](#environment-variables)
- [Usage](#rocket-usage)
  - [Create Docker VPS](#create-docker-vps)
  - [Create Docker Swarm cluster](#create-docker-swarm-cluster)
    - [Create Swarm cluster](#create-swarm-cluster)
      - [Way 1: Using Shell script to auto create `Swarm`](#way-1-using-shell-script-to-auto-create-swarm)
      - [Way 2: Manually create `Swarm`](#way-2-manually-create-swarm)
    - [Visualize Swarm](#visualize-swarm)
- [Practice](#building_construction-practice)
- [Roadmap](#world_map-roadmap)
- [Credits](#sparkles-credits)
- [Related Projects](#link-related-projects)
</details>

# :toolbox: Getting Started

## Prerequisites

Before proceeding with the installation and usage of this project, ensure that you have the following prerequisites in place:

- **Docker Engine:** Docker provides a consistent and portable environment for running applications in containers. Install [here](https://www.docker.com/get-started/).
- **Network Connectivity:** Docker requires network connectivity to download images, communicate with containers, and access external resources.

## Environment Variables

**If you want to auto create Docker Swarm** by [this way](#way-1-using-shell-script-to-auto-create-swarm), you need to add the following environment variables to your `.env` file in `/`:

- **App configs:** Create `.env` file in `./`

  - `NUMBER_OF_WORKERS`: number of workers in Docker Swarm. Default is `2`.
  - `VISUALIZER_PORT`: port of container visualizer service. Default is `8080`.

  Example:

  ```sh
  # .env
  NUMBER_OF_WORKERS=2
  VISUALIZER_PORT=8080
  ```

You can also check out the file `.env.example` to see all required environment variables.

> **Note**: If you want to use this example environment, you need to rename it to `.env`.

# :rocket: Usage

## Create Docker VPS

```sh
docker run -d --privileged --hostname <hostname> --name <container_name> docker:dind
```

## Create Docker Swarm cluster

### Create Swarm cluster

#### Way 1: Using Shell script to auto create `Swarm`

```sh
bash bootstrap.sh
```

#### Way 2: Manually create `Swarm`

Start the init DinD container

```sh
docker run -d --privileged --hostname <hostname_1> --name <container_1> docker:dind
```

Initialize a Docker Swarm on the first DinD container:

```sh
docker exec -it <container_1> docker swarm init
```

Install container visualizer service on the manager node

```sh
# enter the manager node
docker exec -it <container_1> /bin/sh

# install container visualizer service
docker service create \
  --name=visualizer \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```

> **Note:**
>
> - Join-token:
>   - Obtain the join token from the output of the previous command. It should look similar to:  
>     `docker swarm join --token <token> <manager-ip>:<manager-port>`
>   - If you forget the join token, you can get it by running the following command on the manager node: `docker swarm join-token worker`
> - Container visualizer:
>   - You can access the container visualizer service at `http://<manager-ip>:8080`
>   - If port 8080 is already in use on your host, you can specify e.g. `--publish=[YOUR_PORT]:8080/tcp` instead.

Start additional DinD containers and join them to the Swarm

```sh
# Start additional DinD containers
docker run -d --privileged --hostname <hostname_n> --name <container_n> docker:dind

# Join swarm
docker exec -it <container_n> docker swarm join --token <token> <manager-ip>:<manager-port>
```

> **Note:** If you want to attach and control this container, you can use the following command:
> `docker exec -it <container_n> /bin/sh`

### Visualize Swarm

On both way 1 and way 2, you can access the container visualizer service at `http://<manager-ip>:8080`

![Container visualizer](../assets/docker-swarm-cluster/container%20visualizer.png)

<p align="center">
  Container visualizer
</p>

To watch container IP address, you can use the following command:

```sh
docker inspect <container_name>
```

# :building_construction: Practice

You can you can refer to [Docker Swarm lab](https://github.com/QuanBlue/Docker-practice-lab/tree/master/Intermediate/2.%20docker%20swarm/Lab%20%231%3A%20Init%20and%20Manage%20Docker%20Swarm) to create Docker Swarm.

# :world_map: Roadmap

- [x] Create Docker VPS
- [x] Create Docker Swarm
  - [x] Using Shell script
  - [x] Manually
- [x] Visualize Docker Swarm

# :sparkles: Credits

- [Docker](https://www.docker.com/)
- [Docker-in-docker](https://hub.docker.com/_/docker)
- [docker-swarm-visualizer](https://github.com/dockersamples/docker-swarm-visualizer)
- Emojis are taken from [here](https://github.com/arvida/emoji-cheat-sheet.com)

# :link: Related Projects

- <u>[**Docker practice lab**](https://github.com/QuanBlue/Docker-practice-lab)</u>: Practice Docker with Docker, Docker Swarm,... from beginner to advanced.
- <u>[**docker-swarm-visualizer**](https://github.com/dockersamples/docker-swarm-visualizer)</u>: Visualize Docker Swarm

---

> Bento [@quanblue](https://bento.me/quanblue) &nbsp;&middot;&nbsp;
> GitHub [@QuanBlue](https://github.com/QuanBlue) &nbsp;&middot;&nbsp; Gmail quannguyenthanh558@gmail.com
