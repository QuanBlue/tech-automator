<h1 align="center">
  <img src="./assets/ansible.png" alt="icon" width="200"></img>
  <br>
  <b>Ansible VPS Generator</b>
</h1>

<p align="center">Automatically create Ansible and Ubuntu VPSs, connect them and generate Inventory file</p>

<!-- Badges -->
<p align="center">
  <a href="https://github.com/QuanBlue/ansible-vps-generator/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/QuanBlue/ansible-vps-generator" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/QuanBlue/ansible-vps-generator" alt="last update" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/network/members">
    <img src="https://img.shields.io/github/forks/QuanBlue/ansible-vps-generator" alt="forks" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/stargazers">
    <img src="https://img.shields.io/github/stars/QuanBlue/ansible-vps-generator" alt="stars" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/issues/">
    <img src="https://img.shields.io/github/issues/QuanBlue/ansible-vps-generator" alt="open issues" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/QuanBlue/ansible-vps-generator.svg" alt="license" />
  </a>
</p>

<p align="center">
  <b>
    <a href="https://github.com/QuanBlue/ansible-vps-generator">Documentation</a> •
    <a href="https://github.com/QuanBlue/ansible-vps-generator/issues/">Report Bug</a> •
    <a href="https://github.com/QuanBlue/ansible-vps-generator/issues/">Request Feature</a>
  </b>
</p>
<br/>
<details open>
<summary><b>Table of Contents</b></summary>

-  [Getting Started](#toolbox-getting-started)
   -  [Prerequisites](#prerequisites)
   -  [Environment Variables](#environment-variables)
-  [Usage](#rocket-usage)
-  [Roadmap](#world_map-roadmap)
-  [Contributors](#busts_in_silhouette-contributors)
-  [Credits](#sparkles-credits)
-  [License](#scroll-license)
</details>

# :toolbox: Getting Started

## Prerequisites

Before proceeding with the installation and usage of this project, ensure that you have the following prerequisites in place:

-  **Docker Engine:** Docker provides a consistent and portable environment for running applications in containers. Install [here](https://www.docker.com/get-started/).
-  **Network Connectivity:** Docker requires network connectivity to download images, communicate with containers, and access external resources.

## Environment Variables

**If you want to auto create Docker Swarm** by [this way](#way-1-using-shell-script-to-auto-create-swarm), you need to add the following environment variables to your `.env` file in `/`:
To run this project, you need to add the following environment variables to your `.env` file in `/`:

-  `NUMBER_OF_NODE`: number of clients. Default is `2`.
-  `NETWORK`: Name of network. Default is `ansible-net`.

Example:

```sh
# .env
NUMBER_OF_NODE=2
NETWORK=ansible-net
```

You can also check out the file `.env.example` to see all required environment variables.

> **Note**: If you want to use this example environment, you need to rename it to `.env`.

# :rocket: Usage

> **Note:** This Project using `Docker` to create VPSs

<details>
<summary><b>How to install VPSs manually</b></summary>

-  Create VPS: `ansible` and `ubuntu` containers

-  Setup ssh connection between `ansible` and `ubuntu` containers

   -  Generate `ssh` key for `ansible` container at `/etc/ansible/.ssh/id_rsa`

      ```bash
      ssh-keygen -t rsa -N "" -f /etc/ansible/.ssh/id_rsa
      ```

   -  Install OpenSSH server in `ubuntu` container

      ```sh
      <!-- install openssh-server -->
      apt-get update -y
      apt-get install openssh-server -y

       <!-- start ssh service -->
      service ssh enable
      service ssh start
      ```

   -  Copy `ssh` public key to `ubuntu` container at `/root/.ssh/authorized_keys`

   -  Complete! You can now open ssh connection to `ubuntu` container from `ansible` container by command:
      ```sh
      ssh root@<ubuntu_container_ip>
      ```

-  Create Inventory file

   -  Get IPv4 address of all VPSs

      ```sh
      docker network inspect --format='{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}' ansible-net
      ```

   -  Create Inventory file in `ansible` container at `/etc/ansible/inventory/hosts.ini`

      ```ini
      <!-- ./ansible/inventories/hosts.ini -->

      [controller]
      ansible-controller ansible_host=172.18.0.2

      [node]
      ubuntu-node-1 ansible_host=172.18.0.3
      ubuntu-node-2 ansible_host=172.18.0.4
      ```

</details>

Run this command to start the project:

```sh
bash bootstrap.sh
```

You can watch IPv4 address of all container in "ansible-net" network

```sh
$ docker network inspect --format='{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}' ansible-net

ubuntu-node-1: 172.18.0.3/16
ubuntu-node-2: 172.18.0.4/16
ansible-controller: 172.18.0.2/16
```

> **Note:** If you want to attach and control:
>
> -  **`Ansible`** container: `docker exec -it ansible-controller /bin/sh`
> -  **`Ubuntu`** container: `docker exec -it ubuntu-node-<n> /bin/bash`

# :world_map: Roadmap

-  [x] Auto create Ansible and Ubuntu VPSs
-  [x] Auto create Inventory file for Ansible base on VPSs IPv4

# :busts_in_silhouette: Contributors

<a href="https://github.com/QuanBlue/Linux-Bootstrap/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=QuanBlue/Linux-Bootstrap" />
</a>

Contributions are always welcome!

# :sparkles: Credits

-  [Docker](https://www.docker.com/)
-  [Ansible](https://www.ansible.com/)
-  Emojis are taken from [here](https://github.com/arvida/emoji-cheat-sheet.com)

# :scroll: License

Distributed under the MIT License. See <a href="../LICENSE">`LICENSE`</a> for more information.

---

> Bento [@quanblue](https://bento.me/quanblue) &nbsp;&middot;&nbsp;
> GitHub [@QuanBlue](https://github.com/QuanBlue) &nbsp;&middot;&nbsp; Gmail quannguyenthanh558@gmail.com
