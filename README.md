# secure-containers

**Run your applications in tightly confined Podman containers with SELinux.**

<div align="center">

[![Podman](https://img.shields.io/badge/Container-Podman-892CA0?logo=podman&logoColor=white)](https://podman.io/)
[![SELinux](https://img.shields.io/badge/SELinux-MAC-red.svg)](https://selinuxproject.github.io/)
[![Wayland](https://img.shields.io/badge/GUI-Wayland-FFBC00?logo=wayland&logoColor=black)](https://wayland.freedesktop.org/)
[![Bash](https://img.shields.io/badge/Bash-5.x-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

</div>

## Description

secure-containers is a project for running Linux desktop applications in isolated containers with SELinux confinement.

The idea behind the project is to **keep the host system as minimal as possible and keep applications separated from it**. Instead of installing every application directly on the host, applications run in their own containers with limited privileges, while SELinux adds another layer of access control. If an application or one of its dependencies is compromised through a vulnerability, the isolation is intended to limit what it can reach outside its container.

This project is still a starting point. It currently covers only a small set of applications, but the goal is to give others a practical starting point they can understand and build on. Everyone has different applications and different requirements, so feel free to fork the project, adapt the existing setup, and add applications that fit your own needs.

## Features

- **Hardened Containers** — Runs applications with dropped capabilities, no-new-privileges, read-only filesystems, and SELinux enforcement.
- **Custom SELinux Policies** — Provides manually tailored SELinux policies for each container, defining exactly what resources and system capabilities it can access.
- **Per-Container Data Isolation** — Gives each container's persistent data its own SELinux type and restricts access to the intended container and user_t.
- **Container Deployment** — Automates image building, directory setup, Podman configuration, and SELinux policy installation from a single Bash workflow.
- **Wayland Support** — Allows graphical Wayland applications to run inside the confined containers.

## Prerequisites

- Intermediate Linux knowledge
- Basic SELinux knowledge

## Requirements

- Fedora Minimal installation
- Podman
- SELinux enabled and enforcing
- OpenDoas
- Administrative access
- Ethernet connection
- Wayland session for graphical applications

## Getting Started

Clone the repository:

```bash
git clone https://github.com/riseupcoder/secure-containers.git
cd secure-containers
./install.sh
```

After the installation is complete, map your login to the user_u SELinux user:


> [!WARNING]
> **Make sure you have a separate administrator account before running the command below.**
>
> This command changes your current login to the confined `user_u` SELinux user. Your regular account is intended for everyday use, while the separate `sysadm_u` account should be used for administrative tasks.
>
> From your **regular user account**, run:
>
> ```bash
> doas semanage user -m -R "user_r container_user_r" -r s0-s0:c0.c1023 user_u
> doas semanage login -a -s user_u "$USER"
> doas setsebool -P user_t_run_containers on
> ```
>
> Log out and log back in for the new SELinux login mapping to take effect.

## 💬 Discussions

Have a question or want to discuss something? Open a Discussion.

## License
This project is licensed under the MIT License.
