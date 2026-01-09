# Prometheus + Grafana Monitoring Stack

## Objective
Set up a complete monitoring solution using **Prometheus** for metrics collection and **Grafana** for visualization to monitor:
- System metrics
- PostgreSQL database metrics
- MySQL database metrics

This project demonstrates end-to-end setup of exporters, Prometheus, and Grafana dashboards.

---

## Architecture

Node Exporter ─┐  
PostgreSQL Exporter ─┼──> Prometheus ───> Grafana  
MySQL Exporter ──────┘  

---

## Prerequisites
- Ubuntu 20.04 or 22.04
- sudo privileges
- PostgreSQL installed and running
- MySQL installed and running
- Internet access

---

## Step 1: Update System
```bash
sudo apt update && sudo apt upgrade -y

## Step 2: Install Prometheus
Create Prometheus User
sudo useradd --no-create-home --shell /bin/false prometheus

---Create Required Directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

---Download and Install Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
tar xvf prometheus-*.tar.gz
cd prometheus-*/
sudo cp prometheus promtool /usr/local/bin/
sudo cp -r consoles console_libraries /etc/prometheus/

## Step 3: Configure Prometheus
Prometheus Configuration

File: prometheus/prometheus.yml

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: node_exporter
    static_configs:
      - targets: ["localhost:9100"]

  - job_name: postgres_exporter
    static_configs:
      - targets: ["localhost:9187"]

  - job_name: mysql_exporter
    static_configs:
      - targets: ["localhost:9104"]

---Prometheus Service

File: prometheus/prometheus.service

[Unit]
Description=Prometheus
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target

Start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

## Step 4: Install Node Exporter (System Metrics)
sudo useradd --no-create-home --shell /bin/false node_exporter

cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvf node_exporter-*.tar.gz
sudo cp node_exporter-*/node_exporter /usr/local/bin/

Node Exporter Service

File: exporters/node_exporter.service

[Unit]
Description=Node Exporter

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

## Step 5: PostgreSQL Exporter
Create PostgreSQL Monitoring User
sudo -u postgres psql

CREATE USER exporter WITH PASSWORD 'exporterpass';
GRANT pg_monitor TO exporter;
\q

Install PostgreSQL Exporter
cd /tmp
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz
tar xvf postgres_exporter-*.tar.gz
sudo cp postgres_exporter-*/postgres_exporter /usr/local/bin/

---PostgreSQL Exporter Service

File: exporters/postgres_exporter.service

[Unit]
Description=PostgreSQL Exporter

[Service]
Environment=DATA_SOURCE_NAME=postgresql://exporter:exporterpass@localhost:5432/postgres?sslmode=disable
ExecStart=/usr/local/bin/postgres_exporter

[Install]
WantedBy=default.target

sudo systemctl daemon-reload
sudo systemctl enable postgres_exporter
sudo systemctl start postgres_exporter

## Step 6: MySQL Exporter
Create MySQL Monitoring User
sudo mysql

CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'exporterpass';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
FLUSH PRIVILEGES;
EXIT;

Create Credentials File
sudo nano /etc/mysql_exporter.cnf

[client]
user=exporter
password=exporterpass

sudo chmod 600 /etc/mysql_exporter.cnf

---Install MySQL Exporter
cd /tmp
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.0/mysqld_exporter-0.15.0.linux-amd64.tar.gz
tar xvf mysqld_exporter-*.tar.gz
sudo cp mysqld_exporter-*/mysqld_exporter /usr/local/bin/

---MySQL Exporter Service

File: exporters/mysql_exporter.service

[Unit]
Description=MySQL Exporter

[Service]
ExecStart=/usr/local/bin/mysqld_exporter \
  --config.my-cnf=/etc/mysql_exporter.cnf

[Install]
WantedBy=default.target

sudo systemctl daemon-reload
sudo systemctl enable mysql_exporter
sudo systemctl start mysql_exporter

## Step 7: Verify Prometheus Targets

Open:

http://<server-ip>:9090/targets


All targets must show UP:

prometheus

node_exporter

postgres_exporter

mysql_exporter


## Step 8: Install Grafana
sudo apt install -y apt-transport-https
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install grafana -y
sudo systemctl enable grafana-server
sudo systemctl start grafana-server


Access Grafana:

http://<server-ip>:3000


Login:

admin / admin

## Step 9: Connect Grafana to Prometheus

Grafana → Settings → Data Sources

Type: Prometheus

URL: http://localhost:9090

Save & Test

Step 10: Import Grafana Dashboards
Metric Type	Dashboard ID
System Metrics	1860
PostgreSQL Metrics	9628
MySQL Metrics	7362