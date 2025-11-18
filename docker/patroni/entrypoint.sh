#!/bin/sh

readonly CONTAINER_IP=$(hostname --ip-address)
readonly CONTAINER_API_ADDR="${CONTAINER_IP}:${PATRONI_API_CONNECT_PORT}"
readonly CONTAINER_POSTGRE_ADDR="${CONTAINER_IP}:5432"

export PATRONI_NAME="${PATRONI_NAME:-$(hostname)}" 
export PATRONI_RESTAPI_CONNECT_ADDRESS="$CONTAINER_API_ADDR" #adress for restapi connect 
export PATRONI_RESTAPI_LISTEN="$CONTAINER_API_ADDR" #adress where listen restapi 
export PATRONI_POSTGRESQL_CONNECT_ADDRESS="$CONTAINER_POSTGRE_ADDR" # adress to connect to postgres
export PATRONI_POSTGRESQL_LISTEN="$CONTAINER_POSTGRE_ADDR" # adress from where listen postgres clients
export PATRONI_REPLICATION_USERNAME="$REPLICATION_NAME" # username  for replication user 
export PATRONI_REPLICATION_PASSWORD="$REPLICATION_PASS" # password for replication user
export PATRONI_SUPERUSER_USERNAME="$SU_NAME" #super user name 
export PATRONI_SUPERUSER_PASSWORD="$SU_PASS" #super user password
export PATRONI_approle_PASSWORD="$POSTGRES_APP_ROLE_PASS"  #setting passsword for app role
export PATRONI_approle_OPTIONS="${PATRONI_admin_OPTIONS:-createdb, createrole}" #giving access app role to create db and create roles

exec /usr/bin/patroni /patroni.yml
