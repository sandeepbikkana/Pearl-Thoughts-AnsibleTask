# Pearl-Thoughts-AnsibleTask
# Ansible Infrastructure Setup – Nginx, MySQL, PostgreSQL, Docker Swarm

## Overview
This project uses **Ansible** to provision and configure the following components on a **remote Ubuntu EC2 VM**, using a **local machine as the Ansible controller**:

- Nginx web server
- MySQL database (with user and sample data)
- PostgreSQL database (with user and sample data)
- Docker Engine
- Docker Swarm (single-node)
- Log identification and log rotation for databases

All components are automated using **Ansible roles** and validated individually before being executed together using a master playbook.

---

## Architecture

Local Machine (Ansible Controller)
|
| SSH (Key-based)
|
Remote Ubuntu EC2 VM
├── Nginx
├── MySQL
├── PostgreSQL
├── Docker
└── Docker Swarm


---

## Project Structure

ansible/
├── ansible.cfg
├── site.yaml
├── inventory/
│ └── hosts.ini
├── group_vars/
│ └── servers.yaml
├── roles/
│ ├── nginx/
│ ├── mysql/
│ │ ├── tasks/
│ │ │ └── main.yaml
│ │ └── files/
│ │ └── seed.sql
│ ├── postgresql/
│ │ ├── tasks/
│ │ │ └── main.yaml
│ │ └── files/
│ │ └── postgres_seed.sql
│ └── docker/
│ └── tasks/
│ └── main.yaml
├── postgres_test.yaml
└── docker_test.yaml


---

## Inventory Configuration

**`inventory/hosts.ini`**
```ini
[servers]
ubuntu-vm ansible_host=<EC2_PUBLIC_IP> ansible_user=ubuntu

Global Variables

group_vars/servers.yaml

mysql_root_password: "StrongRootPass!"
mysql_app_user: "appuser"
mysql_app_password: "AppUserPass!"
mysql_db: "appdb"

postgres_app_user: "pguser"
postgres_app_password: "PgUserPass!"
postgres_db: "pgdb"

Ansible Configuration

ansible.cfg

[defaults]
remote_tmp = /tmp/.ansible-${USER}
allow_world_readable_tmpfiles = True


This configuration avoids ACL-related issues when running PostgreSQL tasks as the postgres user.

How to Run the Project
1. Test Connectivity
ansible -i inventory/hosts.ini servers -m ping

2. Test Roles Individually (Recommended)
PostgreSQL
ansible-playbook -i inventory/hosts.ini postgres_test.yaml

Docker
ansible-playbook -i inventory/hosts.ini docker_test.yaml

3. Run Everything Together

site.yaml

- hosts: servers
  become: yes
  roles:
    - nginx
    - mysql
    - postgresql
    - docker


Run:

ansible-playbook -i inventory/hosts.ini site.yaml

Verification on EC2 VM

SSH into the VM:

ssh ubuntu@<EC2_PUBLIC_IP>

Nginx
systemctl status nginx
curl http://localhost

MySQL
mysql -u appuser -p appdb
SELECT * FROM users;

PostgreSQL
sudo -u postgres psql pgdb
SELECT * FROM customers;

Docker
docker --version
docker run hello-world

Docker Swarm
docker node ls

Log Locations
Component	Log Location
Nginx	/var/log/nginx/
MySQL	/var/log/mysql/error.log
PostgreSQL	/var/log/postgresql/
Docker	journalctl -u docker
----What is Log Rotation?

Log rotation is the process of automatically archiving, compressing, and deleting old log files to prevent disk space exhaustion and service failure.

Linux uses logrotate to manage this.

Log Rotation Configuration
MySQL

/etc/logrotate.d/mysql-server

/var/log/mysql/error.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    create 640 mysql adm
    postrotate
        systemctl reload mysql > /dev/null 2>&1 || true
    endscript
}

PostgreSQL

/etc/logrotate.d/postgresql

/var/log/postgresql/*.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    create 640 postgres adm
    postrotate
        systemctl reload postgresql > /dev/null 2>&1 || true
    endscript
}

Testing Log Rotation

Force log rotation:

sudo logrotate -f /etc/logrotate.conf


Verify rotated logs:

ls -lh /var/log/mysql/
ls -lh /var/log/postgresql/


Ensure services are still running:

systemctl status mysql
systemctl status postgresql

Final Status
Component	Status
Nginx	✅
MySQL	✅
PostgreSQL	✅
Docker	✅
Docker Swarm	✅
Log Rotation	✅
