include .env
export

make_test:
	echo ${PATH_BLACKBOX_EXPORTER_SRC}
	echo ${GCP_PROJECT_ID}
	which docker-machine

setpath:
	export PATH=/home/guildin/.local/bin:/home/guildin/.local:${PATH}

build_fluent:
	cd ${PATH_FLUENT_SRC} && bash ./docker_build.sh .

build_exp_bbox:
	cd ${PATH_BLACKBOX_EXPORTER_SRC} && bash ./docker_build.sh . 

build_exp_mongo:
	cd ${PATH_MONGODB_EXPORTER_SRC} && bash ./docker_build.sh . 

build_prom:
	cd ${PATH_PROMETHEUS_SRC} && bash ./docker_build.sh . 

build_ui:
	cd ${PATH_UI_SRC} && bash ./docker_build.sh . 

build_post:
	cd ${PATH_POST_SRC} && bash ./docker_build.sh . 

build_comment:
	cd ${PATH_COMMENT_SRC} && bash ./docker_build.sh . 

build_alertmgr:
	cd ${PATH_ALERTMANAGER_SRC} && bash ./docker_build.sh . 

pull_mongo:
	docker pull mongo:latest

mon_run:
	cd ${PATH_DOCKER_COMPOSE_YML} && docker-compose up -d
	
build_app:
	build_ui build_post build_comment
        
build_mon:
	build_exp_bbox build_exp_mongo build_prom build_alertmgr

build_all:
	build_app build_mon build_fluent

docker_machine_up:
	export GOOGLE_PROJECT=pure-stronghold-260309
	docker-machine create --driver google --google-project pure-stronghold-260309 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west1-b docker-host 
	export PATH=/home/guildin/.local/bin:${PATH}
	export PATH=/home/guildin/.local:${PATH}
	docker-machine env docker-host

docker_machine_reload:
	export GOOGLE_PROJECT=pure-stronghold-260309
	export PATH=/home/guildin/.local/bin:${PATH}
	export PATH=/home/guildin/.local:${PATH}
	docker-machine env docker-host

docker_machine_down:
	docker-machine rm -y docker-host

compose_app:
	cd ${PATH_DOCKER_COMPOSE_YML} && docker-compose up -d

decompose_app:
	cd ${PATH_DOCKER_COMPOSE_YML} && docker-compose down

compose_mon:
	cd ${PATH_DOCKER_COMPOSE_YML} && docker-compose -f docker-compose-monitoring.yml up -d

compose_log:
	cd ${PATH_DOCKER_COMPOSE_YML} && docker-compose -f docker-compose-logging.yml up -d

decompose_log:
	cd ${PATH_DOCKER_COMPOSE_YML} && docker-compose -f docker-compose-logging.yml down

compose_all: compose_app compose_mon compose_log
### spoils docker hub

push_comment:
	docker push ${USER_NAME}/comment

push_post:
	docker push ${USER_NAME}/post

push_ui:
	docker push ${USER_NAME}/ui

push_prometheus:
	docker push ${USER_NAME}/prometheus

push_exporter_mongo:
	docker push ${USER_NAME}/mongodb_exporter

push_exporter_blackbox:
	docker push ${USER_NAME}/blackbox_exporter

push_alertmgr:
	docker push ${USER_NAME}/alertmanager

push_mon: push_prometheus push_exporter_mongo push_exporter_blackbox push_alertmgr

push_app: push_comment push_post push_ui

