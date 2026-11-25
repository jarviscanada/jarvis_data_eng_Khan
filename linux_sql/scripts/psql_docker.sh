#!/bin/bash
# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3
# Start docker if it is not running
sudo systemctl status docker> /dev/null 2>&1 || sudo systemctl start docker
# Check whether the container exists (0 means it exists)
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?
# Handle create, start and stop
case $cmd in
	create)
# Fail if the container already exists
		if [ $container_status -eq 0 ]; then
			echo 'Container already exists'
			exit 1
		fi

# Fail if username or password is missing
		if [ $# -ne 3 ]; then
			echo 'Create requires username and password'
			exit 1
		fi

# Create the volume and the container
		docker volume create pgdata
		docker run --name jrvs-psql -e POSTGRES_USER=$db_username -e POSTGRES_PASSWORD=$db_password -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
		exit $?
		;;

	start|stop)

# Fail if the container has not been created
		if [ $container_status -ne 0 ]; then
			echo 'Container has not been created'
			exit 1
		fi

# Start or stop the container
		docker container $cmd jrvs-psql
		 exit $?
		 ;;

	*)
# Any other command is invalid
		echo 'Illegal command'
		 echo 'Commands: start|stop|create'
		 exit 1
		 ;;
	esac
