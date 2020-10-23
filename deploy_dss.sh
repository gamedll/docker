#!/bin/bash
#自动下载配置DSS系统部署文件
echo "开始创建.env配置文件"
path=$(pwd)
cat > .env << EOF
APP_VERSION="v1.0.1.6"
PG_HOST=192.168.0.145
PG_PORT=15432
PG_USER=postgres
PG_PWD=dds_postgres
PG_DATA=dss
S_HOST=192.168.0.145
S_PORT=22
S_USER=root
S_PWD=root
REDIS_HOST=192.168.0.145
REDIS_PORT=6379
REDIS_DATA="0"
REDIS_PWD=dds_redis
RABBIT=192.168.0.145
RABBIT_PORT=5672
RABBIT_HTTP=15672
RABBIT_USER=guest
RABBIT_PWD=guest
TASK_URL_DELETE=http://dsstask:8002/task/delete
EOF
echo "开始创建docker-compose.yml部署文件"
cat > docker-compose.yml << EOF

version: '3.8'
services:
  DSS_TASK:
    image: hub.cictec.cn:20000/dss/dsstask:${APP_VERSION}
    container_name: dsstask
    ports:
      - "8002:8002"
    environment:
      - PG_HOST=${PG_HOST}
      - PG_PORT=${PG_PORT}
      - PG_DATA=${PG_DATA}
      - PG_USER=${PG_USER}
      - PG_PWD=${PG_PWD}
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
      - REDIS_PWD=${REDIS_PWD}
    volumes:
      - /data/app/dss/logs/task:/usr/local/DSS-Core-Task/log
    network_mode: bridge
  DSS_CORE:
    image: hub.cictec.cn:20000/dss/dsscore:${APP_VERSION}
    container_name: dsscore
    links:
      - DSS_TASK
    ports:
      - "8001:8001"
    environment:
      - PG_HOST=${PG_HOST}
      - PG_PORT=${PG_PORT}
      - PG_DATA=${PG_DATA}
      - PG_USER=${PG_USER}
      - PG_PWD=${PG_PWD}
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
      - REDIS_PWD=${REDIS_PWD}
      - TASK_URL_ADD=${TASK_URL_ADD}
    volumes:
      - /data/app/dss/logs/core:/usr/local/DSS-Core-Service/log
    network_mode: bridge
    depends_on:
      - "DSS_TASK"
  DSS_API:
    image: hub.cictec.cn:20000/dss/dssapi:${APP_VERSION}
    container_name: dssapi
    links:
      - DSS_TASK
    ports:
      - "8080:8081"
    environment:
      - PG_HOST=${PG_HOST}
      - PG_PORT=${PG_PORT}
      - PG_DATA=${PG_DATA}
      - PG_USER=${PG_USER}
      - PG_PWD=${PG_PWD}
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
      - REDIS_PWD=${REDIS_PWD}
      - TASK_URL_DELETE=${TASK_URL_DELETE}
      - RABBIT=${RABBIT}
      - RABBIT_PORT=${RABBIT_PORT}
      - RABBIT_HTTP=${RABBIT_HTTP}
      - RABBIT_USER=${RABBIT_USER}
      - RABBIT_PWD=${RABBIT_PWD}
      - S_HOST=${S_HOST}
      - S_PORT=${S_PORT}
      - S_USER=${S_USER}
      - S_PWD=${S_PWD}
      - REDIS_DATA=${REDIS_DATA}
    volumes:
      - /data/app/dss/logs/api:/usr/local/DSS-API/log
    network_mode: bridge
    depends_on:
      - "DSS_TASK"
      - "DSS_CORE"
  DSS_WEB:
    image: hub.cictec.cn:20000/dss/dssweb:${APP_VERSION}
    container_name: dssweb
    links:
      - DSS_API
    ports:
      - "80:80"
    network_mode: bridge

EOF
echo "DSS系统部署文件配置完成，请修改.env中的实际数据配置后执行：docker-compose up -d"
