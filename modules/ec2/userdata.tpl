#!/bin/bash

cd /home/ubuntu/

sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip
sudo apt install -y sqlite3
sudo apt install -y awscli
sudo apt install -y python3-venv
sudo apt install -y libpq-dev
python3 -m venv venv
sudo chown -R ubuntu:ubuntu /home/ubuntu/venv
chmod -R 755 /home/ubuntu/venv
source venv/bin/activate

pip install "apache-airflow[postgres]==2.7.0" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.0/constraints-3.8.txt"
pip install apache-airflow-providers-amazon==7.3.0 boto3==1.26.85 apache-airflow-providers-slack[http] apache-airflow-providers-google


chmod -R 777 /home/ubuntu/airflow

# Export Airflow Home Directory
export AIRFLOW_HOME=/home/ubuntu/airflow
cd /home/ubuntu/
airflow db init
cd /home/ubuntu/airflow/
sed -i '/sql_alchemy_conn =/c\sql_alchemy_conn = postgresql+psycopg2://${db_username}:${db_password}@${db_endpoint}/${db_name}' /home/ubuntu/airflow/airflow.cfg
sed -i '/executor =/c\executor = LocalExecutor' /home/ubuntu/airflow/airflow.cfg
# sed -i 's/^load_examples = True/load_examples = False/' /home/ubuntu/airflow/airflow.cfg
# Generate the FERNET_KEY and export it as an environment variable
export FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

# Use the environment variable in the airflow.cfg file (without the double quotes)
sed -i '/^fernet_key =/c\fernet_key = '"$FERNET_KEY"'' /home/ubuntu/airflow/airflow.cfg

# Grant write permissions to the dags directory

airflow db init

# Create an Airflow admin user
airflow users create \
    --username ${admin_username} \
    --firstname ${admin_firstname} \
    --lastname ${admin_lastname} \
    --role Admin \
    --email ${admin_email} \
    --password ${admin_password}

aws s3 sync s3://${s3_bucket}/dags/ /home/ubuntu/airflow/dags/

chmod -R 777 /home/ubuntu/airflow

# Create and start the systemd service units for Airflow webserver and scheduler
cat << EOF > /etc/systemd/system/airflow-webserver.service
[Unit]
Description=Airflow Webserver Daemon
After=network.target postgresql.service mysql.service redis.service rabbitmq-server.service
Wants=postgresql.service mysql.service redis.service rabbitmq-server.service

[Service]
Type=simple
User=ubuntu
Group=ubuntu
ExecStart=/home/ubuntu/venv/bin/airflow webserver
Restart=on-failure
RestartSec=5s
RuntimeDirectory=airflow
RuntimeDirectoryMode=0755
PrivateTmp=True

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable airflow-webserver.service
sudo systemctl start airflow-webserver.service

cat << EOF > /etc/systemd/system/airflow-scheduler.service
[Unit]
Description=Airflow Scheduler Daemon
After=network.target postgresql.service mysql.service redis.service rabbitmq-server.service
Wants=postgresql.service mysql.service redis.service rabbitmq-server.service

[Service]
Type=simple
User=ubuntu
Group=ubuntu
ExecStart=/home/ubuntu/venv/bin/airflow scheduler
Restart=on-failure
RestartSec=5s
RuntimeDirectory=airflow
RuntimeDirectoryMode=0755
PrivateTmp=True

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable airflow-scheduler.service
sudo systemctl start airflow-scheduler.service