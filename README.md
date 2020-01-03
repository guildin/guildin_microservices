# guildin_microservices

guildin microservices repository

# Курс DevOps 2019-08. Бортовой журнал. Часть 2. Microservices 
Задания со звездочкой отмечаются в журнале литерой *Ж*. Во-первых, символ _астериск_ занят, а во-вторых это немного символично. Самую малось, разумеется.


| [Docker-2](#docker-2) | [Docker GCE](#docker-gce) | [D2 Ж](#d2-ж) | [D2 Задание Ж infra](#d2-задание-ж-infra) |
| --- | --- | --- | --- |
| [Docker-3](#docker-3) | [D3 prerequisites](#d3-prerequisites) | [D3 Задание Ж](#d3-задание-ж) | [D3 Задание Ж2](#d3-задание-ж2) |
| --- | --- | --- | --- |
| [Docker-4](#docker-4) | [D4 Работа с сетью](#d4-работа-с-сетью) | [Docker-compose](#docker-compose) | [D4 Задание Ж](#d4-задание-ж) |
| --- | --- | --- | --- |
| [Gitlab CI 1](#gitlab-ci-1) | [CI/CD Pipeline](#ci/cd-pipeline) | [GCI1 Окружения](#gci1-окружения) | [GCI Задание Ж](#gci-задание-ж) |
| --- | --- | --- | --- |
| [Monitoring-1](#monitoring-1) | [Запуск Prometheus](#запуск-prometheus) | [Образы микросервисов](#образы-микросервисов) | [M1 Задание Ж](#m1-задание-ж) |


# Docker-2

  * Создание docker host
  * Создание своего образа
  * Работа с Docker Hub

## Установка docker
[Источник](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

Установка docker prerequisites
```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

```

Попытка добавить репозиторий:
```sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" # не для АРМ типа mint, собираем из пакетов:```

Установка из пакетов:
```
sudo dpkg -i docker-ce-cli_19.03.5~3-0~debian-stretch_amd64.deb 
sudo dpkg -i containerd.io_1.2.6-3_amd64.deb 
sudo dpkg -i docker-ce_19.03.5~3-0~debian-stretch_amd64.deb 
```
Проверка: docker version \ docker info
Без повышения прав не показывает. Добавим себя в группу docker

### Первый запуск docker
docker run hello-world 

  * docker client запросил у docker engine запуск container из image hello-world  * docker engine не нашел image hello-world локально и скачал его с Docker Hub
  * docker engine создал и запустил container изimage hello-world и передал docker client вывод stdout контейнера
  * Docker run каждый раз запускает новый контейнер
  * Если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске

Запустим docker образа ubuntu 16.04 c /bin/bash:
```
$ docker run -it ubuntu:16.04 /bin/bash
Unable to find image 'ubuntu:16.04' locally
16.04: Pulling from library/ubuntu
e80174c8b43b: Pull complete 
d1072db285cc: Pull complete 
858453671e67: Pull complete 
3d07b1124f98: Pull complete 
Digest: sha256:bb5b48c7750a6a8775c74bcb601f7e5399135d0a06de004d000e05fd25c1a71c
Status: Downloaded newer image for ubuntu:16.04
root@f1791aaf1ee7:/# echo 'Hello world!' > /tmp/file
root@f1791aaf1ee7:/# exit
exit
```

Повторим запуск. Убедимся, что файл /tmp/file отсутствует:
```
$ docker run -it ubuntu:16.04 /bin/bash
root@aa2bb4c515ce:/# cat /tmp/file
cat: /tmp/file: No such file or directory
root@aa2bb4c515ce:/# exit
exit
```

Выведем список контейнеров найдем второй по времени запуска:
```
$ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
CONTAINER ID        IMAGE               CREATED AT                      NAMES
aa2bb4c515ce        ubuntu:16.04        2019-11-25 16:14:44 +0300 MSK   stoic_blackwell
f1791aaf1ee7        ubuntu:16.04        2019-11-25 16:10:52 +0300 MSK   happy_chandrasekhar
4dda79c8a3c0        hello-world         2019-11-25 15:59:06 +0300 MSK   gallant_austin
```
И войдем него:
```
$ docker start f1791aaf1ee7  #  запуск уже имеющегося контейнера
f1791aaf1ee7
$ docker attach f1791aaf1ee7 #  подключение к уже имеющемуся контейнеру
root@f1791aaf1ee7:/# 
root@f1791aaf1ee7:/# cat /tmp/file
Hello world!

```
Ctrl + p, Ctrl + q --> Escape sequence
  
  * docker run => docker create + docker start + docker attach(требуется указать ключ -i) 
  * docker create используется, когда не нужно стартовать контейнер сразу

Ключи запуска:
  * Через параметры передаются лимиты (cpu/mem/disk), ip, volumes 
  * -i  – запускает контейнер в foreground режиме (docker attach) 
  * -d – запускаетконтейнерв background режиме
  * -t создает TTY 
  * docker run -it ubuntu:16.04 bash
  * docker run -dt nginx:latest

### Docker exec
docker exec запускает новый процесс внтури контейнера
```
docker exec -it f1791aaf1ee7 bash
root@f1791aaf1ee7:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18232  3256 pts/0    Ss+  13:17   0:00 /bin/bash
root        16  1.5  0.0  18232  3360 pts/1    Ss   13:32   0:00 bash
root        25  0.0  0.0  34420  2860 pts/1    R+   13:32   0:00 ps aux
root@f1791aaf1ee7:/# 
```

### Docker commit
  * Создает image из контейнера
  * Контейнер при этом остается запущенным
```
$ docker commit f1791aaf1ee7 guildin/ubuntu-tmp-file
sha256:adaf9cefba52eb5f30e7ad034d9ce608c95a9d900a334504787d40a2540340be
```

```
$ sudo docker images
REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE
guildin/ubuntu-tmp-file   latest              adaf9cefba52        About a minute ago   123MB
ubuntu                    16.04               5f2bf26e3524        3 weeks ago          123MB
hello-world               latest              fce289e99eb9        10 months ago        1.84kB
```

### Docker kill, docker stop

  * kill сразу посылает SIGKILL (безусловное завершение процесса)
  * stop посылает SIGTERM (останов), и через 10 секунд(настраивается) посылает SIGKILL

```
docker ps -q                     #  вывод списка запущенных контейнеров 
docker kill $(sudo docker ps -q) #  завершение процессов запущенных контейнеров.
```

### docker system df
```
$ docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              3                   2                   122.6MB             122.6MB (99%)
Containers          3                   0                   83B                 83B (100%)
Local Volumes       0                   0                   0B                  0B
Build Cache         0                   0                   0B                  0B
```
docker system df отображает количество дискового пространства, занятого образами, контейнерами и томами. Кросме того, отображается количество неиспользуемых ресурсов.

### Docker rm & rmi

  * docker rm уничтожает контейнер, запущенный с ключом -f посылает sigkill работающему контейнеру и после удаляет его.
  * docker rmi удаляет образ, если от него не запущены действующие контейнеры.

## Docker GCE
В GCE создадим проект pure-stronghold-260309 (https://console.cloud.google.com/compute)

проведем gcloud init и выберем созданный проект
Настроим авторизацию для приложений: 
```gcloud auth application-default login```

В результате выполнения данныые для авторизации помещены в ~/.config/gcloud/application_default_credentials.json

Скачаем docker-machine:
```
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
```

docker-machine - встроенный в докер инструмент для создания хостов и установки на
них docker engine, c поддержкой облаков и систем виртуализациию 
  * docker-machine create <имя>. - создание машины
  * eval $(docker-machine env <имя>) - Переключение между машинами
  * eval $(docker-machine env --unset). Переключение на локальный докер
  * docker-machine rm <имя> - Удаление

docker-machine создает хост для докер демона со указываемым образом в --google-
machine-image, в ДЗ используется ubuntu-16.04. Образы которые используются для
построения докер контейнеров к этому никак не относятся.

Переключимся на проект в GCP:
```export GOOGLE_PROJECT=pure-stronghold-260309```

Создадим хост:
```
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host 
```

Проверим работоспособность:
```
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                       SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://35.205.228.5:2376           v19.03.5   
```

Переключимся на созданный инстанс:
```eval $(docker-machine env docker-host)```

Приступим:
...Отступим. Повторить демо по:
  * PID namespace (изоляция процессов)
  * net namespace (изоляция сети)
  * user namespaces (изоляция пользователей)

Для реализации docker-in-docker можно использовать образ, взятый отсюда: https://github.com/jpetazzo/dind
Референс по user namespace: https://docs.docker.com/engine/security/userns-remap/

Запустим htop в контейнере tehbilly, чтобы посмотреть на то, как проходит изоляция пространства имен pid:
docker run --rm -ti tehbilly/htop
- только pid 1 (собственно htop)

docker run --rm --pid host -ti tehbilly/htop
- все pid  хостовой машины

Сбор контейнера:

Dockerfile: 
```
FROM ubuntu:16.04                                                                      # начальный образ

RUN apt-get update                                                                     # обновление репозитория и сборка приложения.
RUN apt-get install -y mongodb-server ruby-full ruby-dev build-essential git
RUN gem install bundler
RUN git clone -b monolith https://github.com/express42/reddit.git
                                                                                       
COPY mongod.conf /etc/mongod.conf                                                      # конфигурация СУБД
COPY db_config /reddit/db_config                                                       # конфигурация приложения - указание на БД
COPY start.sh /start.sh                                                                # запуск puma
RUN cd /reddit && bundle install
RUN chmod 0755 /start.sh

CMD ["/start.sh"]
```

mongod.conf
```
# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1
```

db_config
```DATABASE_URL=127.0.0.1```

start.sh
```
#!/bin/bash

/usr/bin/mongod --fork --logpath /var/log/mongod.log --config /etc/mongodb.conf

source /reddit/db_config

cd /reddit && puma || exit
```

### D2 сборка контейнера: 
```
docker build -t reddit:latest .
...
Successfully built f26484a9f238
Successfully tagged reddit:latest
```

Просмотрим образы:
```
$ docker images -a
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
reddit                    latest              f26484a9f238        4 minutes ago       692MB
<none>                    <none>              199bef3ed7df        4 minutes ago       692MB
<none>                    <none>              1306a6de06af        4 minutes ago       692MB
<none>                    <none>              55ddabaa7351        5 minutes ago       647MB
<none>                    <none>              40a0a3f6d355        5 minutes ago       647MB
<none>                    <none>              e2c00a09abdc        5 minutes ago       647MB
<none>                    <none>              a38ae11b7bf9        5 minutes ago       647MB
<none>                    <none>              c633a0bad0c8        6 minutes ago       647MB
<none>                    <none>              934551b71605        6 minutes ago       644MB
<none>                    <none>              d6d8d4e4239c        22 minutes ago      148MB
```

Запуск контейнера:
```
$ sudo docker run --name reddit -d --network=host reddit:latest
7ba4a4c00bdbea6229686df286c663956209356df5e61c7f74da2e9ce3d9ee72
```
Просмотр машин:
```
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                       SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://35.205.228.5:2376           v19.03.5
```

Попробуем открыть http://35.205.228.5:9292/ --> fail
Конечно же, мы помним про брандмауэр. 
```
$ gcloud compute firewall-rules create reddit-app \
> --allow tcp:9292 \
> --target-tags=docker-machine \
> --description="Allow PUMA connections" \
> --direction=INGRESS
Creating firewall...⠶Created [https://www.googleapis.com/compute/v1/projects/pure-stronghold-260309/global/firewalls/reddit-app].
Creating firewall...done.
NAME        NETWORK  DIRECTION  PRIORITY  ALLOW     DENY  DISABLED
reddit-app  default  INGRESS    1000      tcp:9292        False
```

Авторизация на docker hub (https://hub.docker.com)

WARNING! Your password will be stored unencrypted in ~/.docker/config.json

Загрузим наш образ на docker hub для использования в будущем
$ sudo docker tag reddit:latest guildin/otus-reddit:1.0
$ sudo docker push guildin/otus-reddit:1.0

Попробуем запустить:
```
docker run --name reddit -d -p 9292:9292 guildin/otus-reddit:1.0
docker: Error response from daemon: Conflict. The container name "/reddit" is already in use by container "697279e376a2754c604ded22bb32e571d824c2da1da874831acedc32e9b5523f". You have to remove (or rename) that container to be able to reuse that name.
```
Допустим. А вот так?unfortunately, also not
```
$ docker run --name reddit1 -d -p 9292:9292 guildin/otus-reddit:1.0
0ddb84284b2490b7555de400774e909267eefc69cdc0ee598a6fe034e7926f3c
```
Проверим:
```
$ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
CONTAINER ID        IMAGE                     CREATED AT                      NAMES
0ddb84284b24        guildin/otus-reddit:1.0   2019-12-01 00:17:27 +0300 MSK   reddit1
697279e376a2        reddit:latest             2019-11-28 00:41:10 +0300 MSK   reddit
```
Прибьем оба контейнера, в GCE и локально, пересоздадим локальный по новой.

Еще проверки:
  * ```docker logs reddit -f``` Просмотр stdout контейнера в detached mode
  * ```docker exec -it reddit bash ps aux killall5 1``` 
  * ```docker start reddit```
  * ```docker stop reddit && docker rm reddit``` останов и закрытие контейнера
  * ```docker run --name reddit --rm -it dockerhubusername/otus-reddit:1.0 bash ps aux exit```

И еще:
```
#просмотр данных контейнера (json)
$ docker inspect guildin/otus-reddit:1.0

#просмотр данных с фильтрацией json по '{{.ContainerConfig.Cmd}}' -т. е. по совершаемым операциям
$ sudo docker inspect guildin/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
[/bin/sh -c #(nop)  CMD ["/start.sh"]]

$ docker run --name reddit -d -p 9292:9292 guildin/otus-reddit:1.0 # вообще он уже создан, но допустим
$ docker exec -it reddit bash
root@8bef401d5a8d:/# mkdir /test1234
root@8bef401d5a8d:/# touch /test1234/testfile
root@8bef401d5a8d:/# rmdir /opt 
root@8bef401d5a8d:/# exit
exit

$ docker diff reddit
C /tmp
A /tmp/mongodb-27017.sock
C /var
C /var/log
A /var/log/mongod.log
C /var/lib
C /var/lib/mongodb
A /var/lib/mongodb/journal
A /var/lib/mongodb/journal/j._0
A /var/lib/mongodb/journal/prealloc.1
A /var/lib/mongodb/journal/prealloc.2
A /var/lib/mongodb/local.0
A /var/lib/mongodb/local.ns
A /var/lib/mongodb/mongod.lock
A /var/lib/mongodb/_tmp
C /root
A /root/.bash_history
A /test1234
A /test1234/testfile
D /opt
$ docker stop reddit && sudo docker rm reddit
reddit

$ docker run --name reddit --rm -it guildin/otus-reddit:1.0 bash
root@077ddf76b379:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  reddit  root  run  sbin  srv  start.sh  sys  tmp  usr  var
root@077ddf76b379:/# exit
```

# D2 Задание Ж
Теперь, когда есть готовый образ с приложением, можно автоматизировать поднятие нескольких инстансов в GCP, установку на них докера и запуск там образа guildin/otus-reddit:1.0
Нужно реализовать в виде прототип в директории /docker-monolith/infra/

  * Поднятие инстансов с помощью Terraform, их количество задается переменной;
  * Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
  * Шаблон пакера, который делает образ с уже установленным Docker;

Формулировка задачи
1. Запилить образ пакером, т.к. терраформ сам будет долго-долго. из образа ubuntu1604 (раз уж везде он) плейбуком packer_docker.yml раскатать докер-машину (docker-machine ни при чем).
2. Динамический инвентори (возьмем старый) + плейбук для запуска образа приложения. Режьте ножом, пропущу установку докера, т.к. см. пункт 1
3. Развертывание 2х (или более, но будем экономить!) машин через терраформ.

## before you begin
скопируем файл .gitignore из infra репозитория. Безопасность должна быть безопасной )))

## Выпечка образа.
Все уже запилено до нас. Сопрем плейбук [отсюда](https://gist.github.com/rbq/886587980894e98b23d0eee2a1d84933) (в девичестве docker.yaml, вообще не смешно пытаться делать его ручками):
Конечный файл infra/ansible/packer_docker.yml  (С первого раза, конечно, не взлетело, но become: yes творит чудеса)

Выпечем образ base-dm
```
$ packer build -var-file packer/variables.bdm.json packer/base-dm.json 
...
==> Builds finished. The artifacts of successful builds are:
--> googlecompute: A disk image was created: base-dm
```

## Развертывание terraform

Возьмем из репозитория infra конфигурацию, включающую в себя модули db и vpc, в vpc оставим правила брандмауэра на порты 22 и 9292, все что касается db переименуем в docker-inst, укажем диск base-dm в качестве исходного образа.
Развернем получившийся экземпляр, скачаем образ guildin/otus-reddit:1.0
Докачивается мегабайт 600, извините, но нет. Вернемся к пакеру и добавим ансиблу убедительную просьбу скачать образ заранее. 

packer_docker.yml
```
...
  - name: Install DockerPTY # без этого пакета следующая задача выдаст охранный знак и зафейлится
    apt:
      name: python-dockerpty
      update_cache: yes

  - name: pull an image
    docker_image:
      name: guildin/otus-reddit:1.0
      source: pull
```
Тогда останется только запустить контейнер. Ансиблом, конечно. Хотелось бы, конечно, сказать фас терраформу, но он (позор!) не имеет built-in провижинера ansible. Всяких шефов и солт умеет, ну и ладно. Использовать сторонние проекты не будем, вернемся к нашему всему: к динамическому инвентори.

## Динамический инвентори

Выкинем лишнее из старого динамического инвентори и сохраним в файл inventory-parser.sh
Файл формирует json-список хостов, укажем ансиблу на него:
```$ ansible-playbook -i dynamic-inventory.json docker_run.yml```

Что у нас в docker_run.yml
```
---
- hosts: all
  become: yes
  tasks:
  - name: Start container, connect to network and link
    docker_container:
      name: reddit
      image: guildin/otus-reddit:1.0
      ports:
      - "80:9292" #ну наконец то!
```

# Docker-3

## D3 prerequisites

### linter

Рекомендуемое решение - [hadolint](https://github.com/hadolint/hadolint) от lorenzo
Для установки требуются пакеты stack и haskell
```
sudo apt install stack
curl -sSL https://get.haskellstack.org/ | sh
sudo apt-get install haskell-platform
echo "export PATH=/home/guildin/.local/bin:$PATH" >> ~/.profile
```

Установка:
```
git clone https://github.com/hadolint/hadolint
cd hadolint
stack install
```

Во всех образах, с которыми мы будем работать в этом задании, используются неоптимальные инструкции, требуются обратить на это внимание и исправить.

Новая структура приложения

Внутри репозитория у нас появится
microservices , переименуйте его в src
каталог
reddit-
Каталог src теперь основной каталог этого домашнего задания
Теперь наше приложение состоит из трех компонентов:
post-py - сервис отвечающий за написание постов
comment - сервис отвечающий за написание комментариев
ui - веб-интерфейс, работающий с другими сервисами
Для работы нашего приложения также требуется база данных
MongoDB

Подготовка к деплою:
```
wget https://github.com/express42/reddit/archive/microservices.zip
unzip microservices.zip 
mv reddit-microservices/ src
rm microservices.zip 
```
src будет основным каталогом в данной работе.


Dockerfile:
```
$ cat post-py/Dockerfile
FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
```

Сервис comment
```
$ cat comment/Dockerfile 
FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
```

Сервис ui
```
$ cat ui/Dockerfile 
FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```

Скачаем последний образ MongoDB:
```sudo docker pull mongo:latest```

Соберем образы с нашими сервисами:
```
docker build -t guildin/post:1.0 ./post-py
docker build -t guildin/comment:1.0 ./comment
docker build -t guildin/ui:1.0 ./ui
```

Траблшутинг:
В alpine ~все выключено~ нет gcc, поэтому сборка из post-py вываливается с ошибкой:
```
    unable to execute 'gcc': No such file or directory
    error: command 'gcc' failed with exit status 1
```

Красивое решение позаимствовано у vscoder (самому додуматься до пихания все в один RUN не судьба):
```
RUN apk add --no-cache --virtual .build-deps build-base \
  && pip install -r /app/requirements.txt \
  && apk del .build-deps
```

Сеть для решения: ```docker network create reddit```

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post guildin/post:1.0
docker run -d --network=reddit --network-alias=comment guildin/comment:1.0
docker run -d --network=reddit -p 9292:9292 guildin/ui:1.0

### Проверка:
```$ curl http://34.77.120.179 --> fail```

Ну да, порт проброшен но не разрешен для хоста:
```gcloud compute firewall-rules create docker-host-http --allow tcp:80 --source-ranges=0.0.0.0/0```

Повтор:
```
$ curl http://34.77.120.179
<!DOCTYPE html>
...
```
Почистим за собой: ```gcloud compute firewall-rules delete docker-host-http```

#### Сетевые алиасы могут быть использованы для сетевых соединений, как доменные имена
Контейнерам в пределах одного docker доступно разрешение имен, указанных при запуске в ```--network-alias=ALIAS```
Это весьма удобно для разработчиков, да и опсу куда как приятнее.

## D3 Задание Ж

  * Остановим контейнеры:
```$ docker kill $(docker ps -q)```

  * Запустите контейнеры с другими сетевыми алиасами. Адреса для взаимодействия контейнеров задаются через ENV -переменные внутри Dockerfile 'ов.
1. Добавим 1 к сетевым алиасам:
```
docker run -d --network=reddit --network-alias=post_db1 --network-alias=comment_db1 mongo:latest
docker run -d --network=reddit --network-alias=post1 guildin/post:1.0
docker run -d --network=reddit --network-alias=comment1 guildin/comment:1.0
docker run -d --network=reddit -p 80:9292 guildin/ui:1.0
```
  * При запуске контейнеров ( docker run ) задайте им переменные окружения соответствующие новым сетевым алиасам, не пересоздавая образ
2. Укажем переменные окружения ( -e KEY=value ):
```
docker run -d --network=reddit --network-alias=post_db1 --network-alias=comment_db1 mongo:latest
docker run -d -e POST_DATABASE_HOST=post_db1 --network=reddit --network-alias=post1 guildin/post:1.0
docker run -d -e COMMENT_DATABASE_HOST=comment_db1 --network=reddit --network-alias=comment1 guildin/comment:1.0
docker run -d -e POST_SERVICE_HOST=post1 -e COMMENT_SERVICE_HOST=comment1 --network=reddit -p 80:9292 guildin/ui:1.0

```
  * Проверьте работоспособность сервиса - готово.

## D3 образы приложения

Рассмотрим образы:
```
$ docker images 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
guildin/ui          1.0                 7a035dea5fbc        10 hours ago        783MB
guildin/comment     1.0                 988fdf301509        10 hours ago        781MB
guildin/post        1.0                 bbac7ac2daf8        10 hours ago        109MB
mongo               latest              965553e202a4        4 weeks ago         363MB
ruby                2.2                 6c8e6f9667b2        19 months ago       715MB
python              3.6.0-alpine        cb178ebbf0f2        2 years ago         88.6MB
```

Попробуем уменьшить размер образа ui, собрав его FROM ubuntu:16.04 
Новая редакция ui/Dockerfile
```
$ cat ui/Dockerfile
FROM ubuntu:16.04
RUN apt-get update \
    && apt-get install -y ruby-full ruby-dev build-essential \
    && gem install bundler --no-ri --no-rdoc

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```

Соберем новый образ:
```docker build -t guildin/ui:1.0 ./ui```

Оценим размер:
```
$ docker images 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
guildin/ui          1.0                 40c8fe9a325c        6 seconds ago       457MB
<none>              <none>              7a035dea5fbc        11 hours ago        783MB
guildin/comment     1.0                 988fdf301509        11 hours ago        781MB
...
```
Как видим, старый образ остался, но данные REPOSITORY и TAG перешли к его правопреемнику

## D3 Задание Ж2
  * Попробуйте собрать образ на основе Alpine Linux
  * Придумайте еще способы уменьшить размер образа. Можете реализовать как только для UI сервиса, так и для остальных ( post , comment )
Все оптимизации проводите в Dockerfile сервиса.
Дополнительные варианты решения уменьшения размера образов можете оформить в виде файла Dockerfile.<цифра> в папке сервиса

Смертельный номер: удалим все образы и контейнеры. От этих слоев в глазах рябит.
```
docker rm $(docker ps -aq)
docker rmi $(docker images -q)
```

Возьмем alpine поновее, надо же попробовать:
```
$ cat ui-alpine/Dockerfile 
FROM alpine:3.10.3

RUN apk add --no-cache --virtual .build-deps build-base \
    && apk add ruby-full ruby-dev \
    && gem install bundler -v 1.17.2 --no-ri --no-rdoc \
    && gem install bson_ext -v '1.12.5' --no-ri --no-rdoc \
    && gem install thrift -v '0.9.3.0' --no-ri --no-rdoc \
    && gem install puma -v '3.12.0' --no-ri --no-rdoc \
    && apk del .build-deps

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```

Все gem install перечисленные в первом RUN лучше бы, верно, запихать в requirements.txt, но для отладки билда и в соотвествии с заданием мы держим их в Dockerfile
--no-ri --no-rdoc избавляет нас от генерации документации. Можно также указать в .gemrc в . директории: ```gem: —no-rdoc  —no-ri```


```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
guildin/ui          0.1                 7ee34a01e2c7        12 seconds ago      76.7MB
alpine              3.10.3              965ea09ff2eb        6 weeks ago         5.55MB
```

Соберем прочие образы для сравнения:
```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
guildin/comment     1.0                 ba7935722014        38 seconds ago      781MB
guildin/post        1.0                 201a6ff86ae5        2 minutes ago       109MB
guildin/ui          0.1                 7ee34a01e2c7        6 minutes ago       76.7MB
mongo               latest              965553e202a4        4 weeks ago         363MB
alpine              3.10.3              965ea09ff2eb        6 weeks ago         5.55MB
ruby                2.2                 6c8e6f9667b2        19 months ago       715MB
python              3.6.0-alpine        cb178ebbf0f2        2 years ago         88.6MB
```

Запустим контейнеры заново и проверим работоспособность решения.
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post guildin/post:1.0
docker run -d --network=reddit --network-alias=comment guildin/comment:1.0
docker run -d --network=reddit -p 80:9292 guildin/ui:0.1
```

### Перезапуск приложения с volume

Запустим уже остановленные контейнеры, убедимся что оставленный пост исчез после останова mongo и начнем прикручивать ей, монге, отдельный том:
```docker volume create reddit_db```
Запустим mongo (остановим и снова запустим). Так то лучше.
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
...
```


# Docker-4

### План работ
  * Работа с сетями в Docker
  * Использование docker-compose

## D4 подготовка

Подключимся к docker-host на gce: ```eval $(docker-machine env docker-host)```

### Грабли:
```$ eval $(docker-machine env docker-host)
Error checking TLS connection: Error checking and/or regenerating the certs: There was an error validating certificates for host "35.233.114.14:2376": x509: certificate is valid for 34.77.120.179, not 35.233.114.14
You can attempt to regenerate them using 'docker-machine regenerate-certs [name]'.
Be advised that this will trigger a Docker daemon restart which might stop running containers.
```
Смена адреса произошла в результате выключения-включения, ```docker-machine regenerate-certs docker-host``` эту проблему решает, но нужно держать в уме предупреждение об остановке запущенных контейнеров.

## D4 Работа с сетью
  * none
  * host
  * bridge

### none-driver
Используем joffotron/docker-net-tools (пакеты bind-tools, net-tools и curl уже на борту):
```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
...
```

### host-driver
```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
br-cba38fb25497 Link encap:Ethernet  HWaddr 02:42:57:EA:90:44
          inet addr:172.18.0.1  Bcast:172.18.255.255  Mask:255.255.0.0
...
docker0   Link encap:Ethernet  HWaddr 02:42:14:B2:24:B2
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
...
ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:0B
          inet addr:10.132.0.11  Bcast:10.132.0.11  Mask:255.255.255.255
...
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
...
```

Запустим 4 раза контейнер:
```docker run --network host -d nginx```
docker ps выдает информацию о единственном запущенном контейнере, остальные в статусе Exited 
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
d17d800278c5        nginx               "nginx -g 'daemon of…"   56 seconds ago      Up 54 seconds                           intelligent_leakey
```

```
$ docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED              STATUS                          PORTS               NAMES
a30fa673f5ce        nginx                 "nginx -g 'daemon of…"   About a minute ago   Exited (1) About a minute ago                       jolly_benz
7980e2af8602        nginx                 "nginx -g 'daemon of…"   About a minute ago   Exited (1) About a minute ago                       stupefied_robinson
4d20f15d04c8        nginx                 "nginx -g 'daemon of…"   About a minute ago   Exited (1) About a minute ago                       epic_jennings
d17d800278c5        nginx                 "nginx -g 'daemon of…"   About a minute ago   Up About a minute                                   intelligent_leakey
...
```
Мы запустили контейнер с хостовой сетью. Очевидно, множество контейнеров с одним интерфейсом не может быть запущено одновременно, на один сокет три ведра не повесить.

Запустим пару контейнеров с сетью none и проверим результат:
```
$ docker run --network none -d nginx
3107c4456e4e862b8bb961d6a7c7a436c132cc067eed6283c35fd6ca3e9c2587
$ docker run --network none -d nginx
89787fdf7b5b5d413ed68cb4e331888aed379bf802c83c26323de9712c9df6de

$ docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS                      PORTS               NAMES
89787fdf7b5b        nginx                 "nginx -g 'daemon of…"   3 seconds ago       Up 2 seconds                                    xenodochial_fermi
3107c4456e4e        nginx                 "nginx -g 'daemon of…"   5 seconds ago       Up 4 seconds                                    youthful_napier
a30fa673f5ce        nginx                 "nginx -g 'daemon of…"   25 minutes ago      Exited (1) 25 minutes ago                       jolly_benz
7980e2af8602        nginx                 "nginx -g 'daemon of…"   25 minutes ago      Exited (1) 25 minutes ago                       stupefied_robinson
4d20f15d04c8        nginx                 "nginx -g 'daemon of…"   25 minutes ago      Exited (1) 25 minutes ago                       epic_jennings
d17d800278c5        nginx                 "nginx -g 'daemon of…"   25 minutes ago      Up 25 minutes                                   intelligent_leakey
...
```

Docker networks
Зашеллимся на docker-host:      ```$ docker-machine ssh docker-host```
Выполним на docker-host машине: ```$ sudo ln -s /var/run/docker/netns /var/run/netns```
Теперь можно просматривать существующие в данный момент net-namespaces с помощью команды: ```$ sudo ip netns```

Задание:
Повторите запуски контейнеров с использованием драйверов none и host и посмотрите, как меняется список namespace-ов.
Примечание: ip netns exec <namespace> <command> - позволит выполнять команды в выбранном namespace

```
docker-user@docker-host:~$ sudo docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS                        PORTS               NAMES
5ea85ea8b7de        nginx                 "nginx -g 'daemon of…"   29 seconds ago      Exited (1) 25 seconds ago                         inspiring_feistel
f1c34f8d68fa        nginx                 "nginx -g 'daemon of…"   31 seconds ago      Exited (1) 26 seconds ago                         strange_clarke
e1b8f9f0182f        nginx                 "nginx -g 'daemon of…"   33 seconds ago      Up 31 seconds                                     gallant_easley
418beccba701        nginx                 "nginx -g 'daemon of…"   39 seconds ago      Up 38 seconds                                     quizzical_ritchie
116ca0c5ac21        nginx                 "nginx -g 'daemon of…"   45 seconds ago      Up 44 seconds                                     mystifying_bouman
4037491d43f7        nginx                 "nginx -g 'daemon of…"   48 seconds ago      Up 46 seconds                                     elegant_dewdney
```
Запущены 3 контейнера с сетью none, контейнер с сетью host запущен один. Проверим ns
```
$ sudo ip netns
ae1c605408da  #none
69fc5fffdcbc  #none
0698693e2485  #none
default       #host
```

### bridge-network-driver
Удалим предыдущую сеть
```$ docker network rm reddit```
Создадим новую - как bridge
```$ docker network create reddit --driver bridge```

```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post guildin/post:1.0
docker run -d --network=reddit --network-alias=comment guildin/comment:1.0
docker run -d --network=reddit -p 80:9292 guildin/ui:1.0
```
Я дико извиняюсь, но все работает. Потому что сетевые алиасы я указал, так что грабли на сей раз пролежали мимо. Но я запомню.

Запустим наш проект в 2-х bridge сетях. Так , чтобы сервис ui не имел
доступа к базе данных.

Пропишем сети:
```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
```

Запустим контейнеры (подвох уже виден заранее):
```
docker run -d --network=back_net --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=back_net --network-alias=post guildin/post:1.0
docker run -d --network=back_net --network-alias=comment guildin/comment:1.0
docker run -d --network=front_net -p 80:9292 guildin/ui:1.0
```
ui, естественно, не умеет в back_net, так как при подключении можно указать лишь одну сеть. Тогда:
```
docker network connect front_net e3f5f0e114e2   # post
docker network connect front_net 944f53d12515   # comment
```

_Все равно не работает. Дебажим:_
- Проверим наличие у post и comment интерфейсов во front_net и back_net - есть.
- ui и db в разных сетях, ок
- ~network-alias - BINGO!!! Вот они, твои аденоиды, щас присадим.~ name. Люблю дурацкие ошибки.
Фактически, "сейчас" растянулось на несколько человекочасов. Пока не обнаружил у zzzorander упоминание директивы --name, которая, на секундочку, была в методичке. 

Итог:
--name (одна штука) дает ссылку на контейнер, вместо генерируемой автоматически. Это имя может использовать как докер хост, так и сами его контейнеры.
--network_alias (один или больше) дает ссылку на контейнер _и_ резолвит его для контейнеров в той же сети. Но не в другой, Карл.

```
docker run -d --network=back_net --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=back_net --name=post --network-alias=post guildin/post:1.0
docker network connect front_net post
docker run -d --name=comment --network=back_net --network-alias=comment guildin/comment:1.0
docker network connect front_net comment
docker run -d --network=front_net -p 80:9292 guildin/ui:1.0
```

### Сетевой стек Linux на docker-host

Зайдем на docker-host и установим bridge-utils
```
$ docker-machine ssh docker-host
...
docker-user@docker-host:~$ sudo apt-get update && sudo apt-get install bridge-utils
```

Выполним ```docker network ls``` и посмотрим id сетей,созданных в рамках проекта.
Выполним ```ifconfig | grep br``` чтобы увидеть bridge-интерфейсы
Выполним ```brctl show br-b30030fff578``` (имя интерфейса, полученное в предыдущей команде), чтобы увидеть назначенные контейнерам виртуальные интерфейсы, например veth3cc5a90

Исследуем iptables хоста
```
sudo iptables -nL -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0          # NAT узлов адресного пространства, назначенных контейнерам front_net
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0          # NAT узлов адресного пространства, назначенных контейнерам back_net
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0          # NAT узлов адресного пространства, назначенных контейнерам bridge
MASQUERADE  tcp  --  10.0.1.4             10.0.1.4             tcp dpt:9292

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:10.0.1.4:9292 # port mapping

```

Рассмотрим процесс docker-proxy:
```
$ ps ax | grep docker-proxy
 4670 pts/0    S+     0:00 grep --color=auto docker-proxy
27574 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 80 -container-ip 10.0.1.4 -container-port 9292
```
Да, мне нравится http на 80м порту. Ничего не могу с собой поделать.

## Docker-compose

  * Установим docker-compose на локальную машину
  * Соберем образы приложения reddit с помощью docker-compose
  * Запустим приложение reddit с помощью docker-compose

### Установка
Установить docker-compose можно (отсюда)[https://docs.docker.com/compose/install/#install-compose] или с помощью:
```
$ pip install docker-compose
...
Cache entry deserialization failed, entry ignored
...
rm -rf ~/.cache/pip
```
После очистки кэша pip install отрабатывает штатно.

создадим в src файл docker-compose.yml
```
version: '3.3'
services:
  post_db:
    image: mongo:3.2
    volumes:
      - post_db:/data/db
    networks:
      - reddit
  ui:
    build: ./ui
    image: ${USERNAME}/ui:1.0
    ports:
      - 80:9292/tcp
    networks:
      - reddit
  post:
    build: ./post-py
    image: ${USERNAME}/post:1.0
    networks:
      - reddit
  comment:
    build: ./comment
    image: ${USERNAME}/comment:1.0
    networks:
      - reddit

volumes:
  post_db:

networks:
  reddit:
```

docker-compose поддерживает интерполяцию (подстановку) переменных окружения.
В данном случае это переменная USERNAME.
Поэтому перед запуском необходимо экспортировать значения данных переменных окружения.

Остановим контейнеры, запущенные на предыдущих шагах
```$ docker kill $(docker ps -q)```

Зададим в качестве username название учетки на docker hub
```
export USERNAME=guildin
```

Выполним команды:
```
$ docker-compose up -d
Creating network "tmp_reddit" with the default driver
Creating volume "tmp_post_db" with default driver
...

$ docker-compose ps
    Name                  Command             State           Ports
----------------------------------------------------------------------------
tmp_comment_1   puma                          Up
tmp_post_1      python3 post_app.py           Up
tmp_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
tmp_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```

Проверим работоспособность проекта, ок.

### docker-compose.yml
Задачи:
1) Изменить docker-compose под кейс с множеством сетей, сетевых алиасов (стр 18).
2) Параметризуйте с помощью переменных окружений:
  * порт публикации сервиса ui
  * версии сервисов
  * возможно что-либо еще на ваше усмотрение
3) Параметризованные параметры запишите в отдельный файл c расширением .env
4) Без использования команд source и export docker-compose должен подхватить переменные из этого файла. Проверьте
P.S. Файл .env должен быть в .gitignore, в репозитории закоммичен .env.example, из которого создается .env

Имена  контейнерам можно задать с помощью ключа container_name.
Кроме того, можно использовать переменную окружения COMPOSE_PROJECT_NAME

## D4 Задание Ж
Создайте docker-compose.override.yml для reddit проекта, который позволит
  * Изменять код каждого из приложений, не выполняя сборку образа
В docker-compose.override.yml указать параметры хранилища puma (методичка [docker-compose](https://docs.docker.com/compose/compose-file/) ).
```
    volumes:
      - ./ui:/app
```
Несмотря на многочисленные примеры такого использования кода, это не работает, монтируемый том пуст. todo.

  * Запускать puma для руби приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2)
1. Запустить ```puma --debug -w 2``` через параметры в docker-compose.override.yml
2. Проверить результат.
Посмотрим имеющиеся контейнеры
```
comment-service   puma Up
ui-service        puma Up      0.0.0.0:80->9292/tcp
```
Через директиву command добавим параметры запуска и пересоздадим контейнеры:
```
comment-service   puma --debug -w 2             Up
ui-service        puma --debug -w 2             Up      0.0.0.0:80->9292/tcp
```
Проверим результат:
```
$ docker exec -it ui-service bash
root@a0f02b78c52f:/app# ps auxf
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root       238  3.1  0.0  18236  3208 pts/0    Ss   21:47   0:00 bash
root       251  0.0  0.0  34424  2768 pts/0    R+   21:47   0:00  \_ ps auxf
root         1  0.1  0.4  69352 16040 ?        Ssl  21:43   0:00 puma 3.12.0 (tcp://0.0.0.0:9292) [app]
root         7  0.3  1.0 669032 39784 ?        Sl   21:43   0:00 puma: cluster worker 0: 1 [app]
root         9  0.3  1.0 669072 39632 ?        Sl   21:43   0:00 puma: cluster worker 1: 1 [app]
```

# Gitlab CI 1

  * Подготовить инсталляцию Gitlab CI
  * Подготовить репозиторий с кодом приложения
  * Описать для приложения этапы пайплайна
  * Определить окружения

[Требования к ВМ](https://docs.gitlab.com/ce/install/requirements.html)
1 CPU / 3.75GB RAM / 50-100 GB HDD / Ubuntu 16.04

Используем стек packer/terraform/ansible для развертывания ВМ (тип машины изменим на n1-standard-1) 
Экземляр развернут, установим gitlab ci:
[Установка GITLAB CI через docker-compose](https://docs.gitlab.com/omnibus/docker/README.html#install-gitlab-using-docker-compose)
```
$ cat docker-compose.yml 
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://104.155.5.188'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab' 
```
Контейнер запущен, несколько минут требуется на запуск gitlab ci.
Установим пароль для root (первый вход), через settings - signup restrictions отключена регистрация новых пользователей. 
  * Каждый проект в Gitlab CI принадлежит к группе проектов
  * В проекте может быть определен CI/CD пайплайн
  * Задачи (jobs) входящие в пайплайн должны исполняться на runners

Создадим группу и проект (homework / example) 
Добавим remote в guildin_microservices^
```
git remote add gitlab http://gitlabci/homework/example.git
git push gitlab gitlab-ci-1
history | tail
```

## CI/CD Pipeline
Перейдем к определению CI/CD Pipeline для проекта.
Чтобы сделать это нам нужно добавить в репозиторий файл [.gitlab-ci.yml](https://gist.github.com/Nklya/ab352648c32492e6e9b32440a79a5113)
Теперь если перейти в раздел CI/CD мы увидим, что пайплайн готов к запуску, но находится в статусе pending / stuck так как у нас нет runner
Запустим Runner и зарегистрируем его в интерактивном режиме
Получим токен (CI/CD -> runners settings - Specific Runners)
токен раннера ygQXv1ZreQwBtdh2xJA9

Выполним на сервере Gitlab CI команду:
```
sudo docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

После запуска Runner нужно зарегистрировать, это можно сделать командой:
```
sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Runtime platform                                    arch=amd64 os=linux pid=33 revision=577f813d version=12.5.0
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://35.233.34.183/
Please enter the gitlab-ci token for this runner:
ygQXv1ZreQwBtdh2xJA9
Please enter the gitlab-ci description for this runner:
[2bdc89760807]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Registering runner... succeeded                     runner=ygQXv1Zr
Please enter the executor: parallels, shell, ssh, virtualbox, docker-ssh+machine, kubernetes, custom, docker, docker-ssh, docker+machine:
docker
Please enter the default Docker image (e.g. ruby:2.6):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
```

  * Добавим исходный код reddit в репозиторий
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab gitlab-ci-1
```

  * Изменим описание пайплайна: 
```
$ cat .gitlab-ci.yml 
image: ruby:2.4.2

stages:
  - build
  - test
  - deploy

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  script:
    - echo 'Testing 1'
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
```

  * В папке reddit создадим файл simpletest.rb [gist](https://gist.github.com/Nklya/d70ff7c6d1c02de8f18bcd049e904942)
  * simpletest использует библиотеку rack-test, отсутствующую в reddit\Gemfile. Добавим ее туда: ```gem 'rack-test'```

## GCI1 Окружения
Вернемся к академическому пайплайну, который описывает шаги сборки, тестирования и деплоймента.
До этого был создан job с названием deploy_job. Разберемся, что и куда будет задеплоено.

### Dev-окружение
Изменим пайплайн таким образом, чтобы deploy_job стал определением окружения dev, на которое условно будет выкатываться каждое изменение в коде проекта.
1. Переименуем deploy stage в review.
2. deploy_job заменим на deploy_dev_job
3. Добавим environment

В operations > environments появится определение первого окружения.

### Staging и Production
Если на dev мы можем выкатывать последнюю версию кода, то к production окружению это может быть неприменимо, если, конечно, вы не стремитесь к continuous deployment. Определим два новых этапа: stage и production, первый будет содержать job имитирующий выкатку на staging окружение, второй на production окружение.
Определим эти job таким образом, чтобы они запускались с кнопки: ```when: manual``` – говорит о том, что job должен быть запущен человеком из UI
```
stages:
  - build
  - test
  - review
  - stage
  - production
...
staging:
  stage: stage
  when: manual
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
```

Обычно, на production окружение выводится приложение с явно зафиксированной версией
(например, 2.4.10).
Добавим в описание pipeline директиву, которая не позволит нам выкатить на staging и production код, не помеченный с помощью тэга в git.
```
  only:
    - /^\d+\.\d+\.\d+/
```
Директива only описывает список условий, которые должны быть истинны, чтобы job мог запуститься.
Регулярное выражение слева означает, что должен стоять semver тэг в git, например, 2.4.10


### GCI Динамические окружения
Определим динамическое окружение для каждой ветки в репозитории, кроме ветки master
```
branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master
```
Теперь, на каждую ветку в git отличную от master Gitlab CI будет определять новое окружение.

## GCI Задание Ж
  * В шаг build добавить сборку контейнера с приложением reddit
Первое, что лезет в голову:
```docker build -t reddit:latest ./docker-monolith```
А нет. Мы в контейнере, а докер в докер делать не хочется, религия.
Попытка вторая - kaniko.
```
sudo docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gcr.io/kaniko-project/executor:debug
```
или так (курить! хрень получается!)
```
build_job:
  stage: build
  before_script: []
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: []
  script:
    - ls -la
    - /kaniko/executor --context ./docker-monolith --dockerfile ./docker-monolith/Dockerfile --no-push
    - build --context ./docker-monolith --dockerfile ./docker-monolith/Dockerfile --no-push
```
  * Деплойте контейнер с reddit на созданный для ветки сервер
Постановка задачи:
- Установим докер-машину и прицепим наш докер хост к gcp. Это вообще рисковый шаг, но полет мысли то какой!
- Создадим в branch review скрипт, создающий докер-хост с именем $CI_ENVIRONMENT_SLUG и все такое. Господи, только бы взлетело!


# monitoring-1

## План
•Prometheus: запуск, конфигурация, знакомство с Web UI 
•Мониторинг состояния микросервисов
•Сбор метри к хоста с использованием экспортера
•Заданиясо *

## Подготовка окружения
Настроим брандмауэр для prometheus (9090) и puma (9292)
```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```

# Запуск Prometheus

Систему мониторинга Prometheus будем запускать внутри Docker контейнера. Для начального знакомства воспользуемся готовым образом с DockerHub.
```docker run --rm -p 9090:9090 -d --name prometheus prometheus:v2.1.0```
Откроем веб-интерфейс: 

http://35.233.34.183:9090/graph

Вкладка Console, которая сейчас активирована, выводит численное значение выражений. Вкладка Graph, левее от нее, строит график изменений значений метрик со временем.
Если кликнем по "insert metric at cursor", то увидим, что Prometheus уже собирает какие-то метрики. По умолчанию он собирает статистику о своей работе. Выберем, например,
метрику prometheus_build_info и нажмем Execute, чтобы посмотреть информацию о версии.
```prometheus_build_info{branch="HEAD",goversion="go1.9.2",instance="localhost:9090",job="prometheus",revision="85f23d82a045d103ea7f3c89a91fba4a93e6367a",version="2.1.0"}```
  * ```prometheus_build_info``` - название метрики
  * ```{key="value",key="value",...}``` метаданные (лейблы). лейблы наряду с именем позволяют не ограничиваться одним лишь названием метрик для идетификации информации.
  * 1 - собственно value. Численное значение или  NaN

Targets
Targets (цели) - представляют собой системы или процессы, за которыми следит Prometheus. Помним, что Prometheus является pull системой, поэтому он постоянно делает HTTP запросы на имеющиеся у него адреса (endpoints). Посмотрим текущий список целей:
Endpoint | State |	Labels |	Last Scrape | Error
http://localhost:9090/metrics |	up | instance="localhost:9090" | 2.226s ago

В Targets сейчас мы видим только сам Prometheus. У каждой цели есть свой список адресов (endpoints), по которым следует обращаться для получения информации.
В веб интерфейсе мы можем видеть состояние каждого endpoint-а (up); лейбл (instance="someURL"), который Prometheus автоматически добавляет к каждой метрике, получаемой с данного endpoint-а; а также время, прошедшее с момента последней операции сбора информации с endpoint-а.
Также здесь отображаются ошибки при их наличии и можно отфильтровать только неживые таргеты.
Обратите внимание на endpoint, который мы с вами видели на предыдущем слайде.
Мы можем открыть страницу в веб браузере по данному HTTP пути (host:port/metrics), чтобы посмотреть, как выглядит та информация, которую собирает Prometheus.
```
http://35.233.34.183:9090/metrics
...
# HELP prometheus_build_info A metric with a constant '1' value labeled by version, revision, branch, and goversion from which prometheus was built.
# TYPE prometheus_build_info gauge
prometheus_build_info{branch="HEAD",goversion="go1.9.2",revision="85f23d82a045d103ea7f3c89a91fba4a93e6367a",version="2.1.0"} 1
...
```
Остановим prometheus: ```docker stop prometheus```

## Реструктуризация директорий
1. Создадим директорию docker в корне репозитория и перенесем в нее
директорию docker-monolith и файлы docker-compose.* и все .env (.env
должен быть в .gitgnore), в репозиторий закоммичен .env.example, из
которого создается .env
2. Создадим в корне репозитория директорию monitoring. В ней будет
хранится все, что относится к мониторингу
3. Не забываем про .gitgnore и актуализируем записи при необходимости
P.S. С этого момента сборка сервисов отделена от docker-compose,
поэтому инструкции build можно удалить из docker-compose.yml.

```vim monitoring/prometheus/Dockerfile```

## Конфигурация
Вся конфигурация Prometheus, в отличие от многих других систем мониторинга, происходит через файлы конфигурации и опции командной строки.
Мы определим простой конфигурационный файл для сбора метрик с наших микросервисов: monitoring/prometheus/[prometheus.yml](https://gist.github.com/Nklya/bfe2d817f72bc6376fb7d05507e97a1d):
```
---
global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'
```
# Образы микросервисов
В коде микросервисов есть healthcheck-и для проверки работоспособности приложения.
Сборку образов теперь необходимо производить при помощи скриптов docker_build.sh, которые есть в директории каждого сервиса. С его помощью мы добавим информацию из Git в наш healthcheck
```#!/bin/bash

echo `git show --format="%h" HEAD | head -1` > build_info.txt
echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt

docker build -t $USER_NAME/ui .
```
Ковырнем инструкции:
```
$ git show --format="%h" HEAD | head -1
7195765
$ git rev-parse --abbrev-ref HEAD
monitoring-1
```
Соберем образы:
```
cd ../../src/ui && bash docker_build.sh
cd ../post-py && bash docker_build.sh
cd ../comment && bash docker_build.sh

```

Для ленивых (надо было самому написать!):
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```

Новый сервис в docker/docker-compose.yml:
```
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'
    networks:
      back_net:
        aliases:
          - prometheus
      front_net:
        aliases:
          - prometheus
...
volumes:
  prometheus_data:
```

Развернем микросервисы: ```docker-compose up -d``` и проверим работоспособность. Готово.

## Мониторинг состояния микросервисов

Посмотрим список endpoint-ов, с которых собирает информацию Prometheus. Помните, что помимо самого Prometheus, мы определили в конфигурации мониторинг ui и comment сервисов. Endpoint-ы должны быть в состоянии UP.
Healthcheck-и представляют собой проверки того, что наш сервис здоров и работает в ожидаемом режиме. В нашем случае healthcheck выполняется внутри кода микросервиса и выполняет проверку того, что все сервисы, от которых зависит его работа, ему доступны.
Если требуемые для его работы сервисы здоровы, то healthcheck проверка возвращает status = 1, что соответсвует тому, что сам сервис здоров.
Если один из нужных ему сервисов нездоров или недоступен, то проверка вернет status = 0

Выберем метрику ui_health и построим график того, как менялось ее значение со временем. Помимо имени метрики и ее значения, мы также видим информацию в лейблах о версии приложения, комите
и ветке кода в Git
Видим, что статус UI сервиса был стабильно 1, что означает, что сервис работал. 
Данный график оставим открытым.

Остановим сервис post и проверим состояние ui_health. Статус разумеется, изменился. Посмотреть хелсчеки сервисов, от которых зависит данный хелсчек можно так: ui_health_
Запустим post обратно и убедимся что ситуация исправилась.

## Сбор метрик хоста

Exporters
Экспортер похож на вспомогательного агента для сбора метрик.
В ситуациях, когда мы не можем реализовать отдачу метрик Prometheus в коде приложения, мы можем использовать экспортер, который будет транслировать метрики приложения или системы в формате доступном для чтения Prometheus.
  * Программа, которая делает метрики доступными для сбора Prometheus
  * Дает возможность конвертировать метрики в нужный для Prometheus формат
  * Используется когда нельзя поменять код приложения
  * Примеры: PostgreSQL, RabbitMQ, Nginx, Node exporter, cAdvisor

## Node exporter

Воспользуемся Node экспортер для сбора и отправки информации о докер хосте в Prometheus.
В docker-compose.yml:
```
services:
  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```

Проверим отображение информации и ее смену в результате, например, повышения нагрузки.

## M1 Задание Ж

### Мониторинг MongoDB

Добавьте в Prometheus мониторинг MongoDB с использованием необходимого экспортера.
• Версию образа экспортера нужно фиксировать на последнюю стабильную
• Если будете добавлять для него Dockerfile, он должен быть в директории monitoring, а не в корне репозитория.


сборка образа экспортера (percona)
```
git clone https://github.com/percona/mongodb_exporter.git
cd mongodb_exporter/
make docker
```
В docker-compose.yml описаны параметры контейнера:
```
  mongodb-exporter:
    build:
      ../../mongodb_exporter
    image: mongodb-exporter:${IMG_MONGODB_EXPORTER}
    container_name: mongodb-exporter
    networks:
      back_net:
        aliases:
          - mongodb-exporter
    environment:
      MONGODB_URI: ${MONGODB_URI}
```
Примечание: MONGODB_URI='mongodb://mongodb-service:27017'
Когда нужно будет атворизоваться на субд, в env также укажем HTTP_AUTH='user:password'. Нет, не укажем, нечего хранить это в открытом виде. Думать.

В prometheus.yml добавил job:
```
  - job_name: 'mongodb-exporter'
    static_configs:
      - targets:
        - 'mongodb-exporter:9216'
```
...и пересобрал образ prometheus.

### Мониторинг веб-служб

Добавьте в Prometheus мониторинг сервисов comment, post, ui с помощью blackbox экспортера.
Blackbox exporter позволяет реализовать для Prometheus мониторинг по принципу черного ящика. Т.е. например мы можем проверить отвечает ли сервис по http, или принимает ли соединения порт.
• Версию образа экспортера нужно фиксировать на последнюю стабильную.
• Если будете добавлять для него Dockerfile, он должен быть в директории monitoring, а не в корне репозитория.
Вместо blackbox_exporter можете попробовать использовать Cloudprober от Google. (todo - сделать обязательно!)

### Реализация
1. ```mkdir monitoring/blackbox_exporter && cd monitoring/blackbox_exporter```

2. ```wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.16.0/blackbox_exporter-0.16.0.linux-amd64.tar.gz && tar xzfv blackbox_exporter-0.16.0.linux-amd64.tar.gz```

3. Dockerfile:
```
FROM        quay.io/prometheus/busybox:latest
MAINTAINER  The Prometheus Authors <prometheus-developers@googlegroups.com>

COPY blackbox_exporter  /bin/blackbox_exporter
COPY blackbox.yml       /etc/blackbox_exporter/config.yml

EXPOSE      9115
ENTRYPOINT  [ "/bin/blackbox_exporter" ]
CMD         [ "-config.file=/etc/blackbox_exporter/config.yml" ]
```

4. prometheus.yml
```
...
  blackbox-exporter:
    container_name: blackbox-exporter
    image: ${USERNAME}/blackbox_exporter:${BLACKBOX_EXPORTER_VERSION}
    ports:
      - 9115:9115/tcp
    networks:
      front_net:
        aliases:
        - blackbox-exporter
    command:
      - '--config.file=/etc/blackbox_exporter/config.yml' 
...
```

5. ```docker build -t guildin/blackbox_exporter:0.16.0 .```
6. ```docker-compose up -d blackbox-exporter```
PS прометея нужно пересобрать, конечно. А лучше вынести ему конфиг в отдельный volume

### Makefile
Как вы могли заметить, количество компонент, для которых необходимо
делать билд образов, растет. И уже сейчас делать это вручную не очень
удобно.
Можно было бы конечно написать скрипт для автоматизации таких действий.
Но гораздо лучше для этого использовать Makefile.
Задание: Напишите Makefile, который в минимальном варианте умеет:
1. Билдить любой или все образы, которые сейчас используются
2. Умеет пушить их в докер хаб
Дополнительно можете реализовать любый сценарии, которые вам кажутся
полезными.

### Реализация
Ох ты прелесть какая!
Только параметризовать долго)
В Makefile записал инструкции вида:
build
```
build_prom:
	cd ${PATH_PROMETHEUS_SRC} && bash ./docker_build.sh . 
#docker build -t ${USER_NAME}/prometheus:${PROMETHEUS_VERSION} .
```

Здесь прошу отметить, нужно ли:
  * использовать первый вариант, чтобы генерился файл build-info.txt и ставился тег latest
  * использовать закомментированный вариант, чтобы чтобы сборка тегировалась номером версии указанным в .env
  * и генерить файл build-info.txt и ставить статический тег версии

...инструкции build_* собраны в кучу в инструкции build_mon1

push
```
push_comment:
	docker push ${USER_NAME}/comment
```
Аналогично, все собрано в кучу в инструкции push_mon1


# Monitoring-2

## План
  * Мониторинг Docker контейнеров
  * Визуализация метрик
  * Сбор метрик работы приложения и бизнес метрик
  * Настройка и проверка алертинга

## Мониторинг Docker-контейнеров

Разделим описание контейнеров. Выделим приложения в docker-compose.yml, а их мониторинг - в docker-compose-monitoring.yml
Запуск приложений останется стандартным, а запуск мониторинга - ```docker-compose -f docker-compose-monitoring.yml up -d```

Для наблюдения за состоянием контейнеров будем использовать [cAdvisor](https://github.com/google/cadvisor)
cAdvisor собирает информацию о ресурсах потребляемых контейнерами и характеристиках их работы:
  * процент использования контейнером CPU и памяти, выделенные для его запуска
  * объем сетевого трафика
  * etc

Добавим контейнер с cAdisor.
Файл docker-compose.yml:
```
version: '3.3'
services:
  post_db:
    image: mongo:${IMG_MONGO_VERSION}
    container_name: mongodb-service
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db
  ui:
    container_name: ui-service
    image: ${USERNAME}/ui:${IMG_UI_VERSION}
    ports:
      - ${H_PORT_UI}:${C_PORT_UI}/tcp
    networks:
      front_net:
        aliases:
          - ui
  post:
    container_name: post-service
    image: ${USERNAME}/post:${IMG_POST_VERSION}
    networks:
      back_net:
        aliases:
          - post
      front_net:
        aliases:
          - post
  comment:
    container_name: comment-service
    image: ${USERNAME}/comment:${IMG_COMMENT_VERSION}
    networks:
      back_net:
        aliases:
        - comment
      front_net:
        aliases:
        - comment

volumes:
  post_db:

networks:
  front_net:
  back_net:

```

Файл docker-compose-monitoring.yml (вместе с cadvisor):
```
version: '3.3'
services:
  mongodb-exporter:
    image: mongodb-exporter:${IMG_MONGODB_EXPORTER}
    container_name: mongodb-exporter
    networks:
      back_net:
        aliases:
          - mongodb-exporter
    environment:
      MONGODB_URI: ${MONGODB_URI}
  prometheus:
    build:
      ../monitoring/prometheus
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'
    networks:
      back_net:
        aliases:
          - prometheus
      front_net:
        aliases:
          - prometheus
  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
    networks:
      back_net:
        aliases:
        - node-exporter

  blackbox-exporter:
    container_name: blackbox-exporter
    image: ${USERNAME}/blackbox_exporter:${BLACKBOX_EXPORTER_VERSION}
    ports:
      - 9115:9115/tcp
    networks:
      front_net:
        aliases:
        - blackbox-exporter
    command:
      - '--config.file=/etc/blackbox_exporter/config.yml'
  cadvisor:
    image: google/cadvisor:v0.29.0
    volumes:
      - '/:/rootfs:ro'
      - '/var/run:/var/run:rw'
      - '/sys:/sys:ro'
      - '/var/lib/docker/:/var/lib/docker:ro'
    ports:
      - '8080:8080'    

volumes:
  prometheus_data:

networks:
  front_net:
  back_net:

```

Добавим cavisor в конфигурацию prometeus:
```
...
- job_name: 'cadvisor'
static_configs:
- targets:
- 'cadvisor:8080'
```
Пересоберем прометея:
```make build_prom```
(если чукча не писатель, то ```docker build -t $USER_NAME/prometheus .``` из каталога с описанием контейнера прометея)

Запустим службы:

```
$ docker-compose up -d
$ docker-compose -f docker-compose-monitoring.yml up -d
```

### !!! Грабли !!!:
```
$ docker-compose -f docker-compose-monitoring.yml up -d
WARNING: Found orphan containers (mongodb-service, comment-service, post-service, ui-service) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Pulling mongodb-exporter (mongodb-exporter:master)...
ERROR: The image for the service you're trying to recreate has been removed. If you continue, volume data could be lost. Consider backing up your data before continuing.
```

[Пояснение](https://stackoverflow.com/questions/50947938/docker-compose-orphan-containers-warning) и траблшутинг:
You get the "Found orphan containers" warning because docker-compose detects some containers which belong to another project with the *same name*.
To prevent different projects from interfering with each other (and suppress the warning) you can set a custom project name by using:
  * -p command line option
  * COMPOSE_PROJECT_NAME environment variable.

Воспользуемся опцией -p:
```docker-compose -p monitoring -f docker-compose-monitoring.yml up -d```

Добавим порт кАдвизора в брандмауэр:
```
gcloud compute firewall-rules create tcp8080 \
 --allow tcp:8080 \
 --target-tags=docker-machine \
 --description="Allow port 8080 connections (cAdvisor)" \
 --direction=INGRESS
```

Проверим cAdvisor: http://docker-host:8080/containers/

Информация по контейнерам: http://35.233.50.190:8080/docker/
Перейдя по названию контейнера можно посмотреть его статистику.
В http://docker-host:8080/metrics собираются метрики для прометея.

Проверим сбор метрик в прометее и увидим что ничего подобного нет. 
Посмотрим существующие контейнеры:
```
CONTAINER ID        IMAGE                              COMMAND                  CREATED              STATUS              PORTS                    NAMES
...
4a3bd5a1bfe3        google/cadvisor:v0.29.0            "/usr/bin/cadvisor -…"   About a minute ago   Up 58 seconds       0.0.0.0:8080->8080/tcp   monitoring_cadvisor_1
f9cd43647290        guildin/mongodb_exporter:master    "/bin/mongodb_export…"   About a minute ago   Up 59 seconds       9216/tcp                 mongodb-exporter
...
```
try: правим имена контейнеров. Нет коннекта.
try: добавим в описание контейнера cAdvisor сеть back_net
После этого прометей получит доступ к кАдвизору. Однако контейнеры, описанные в docker-compose.yml останутся в другой сети. Следовательно, распределение по проектам в данном случае не подходит.
Если вернуть все на место, коммутация между сервисами обоих групп восттановится, но при запуске контейнеров все равно будет выдаваться предупреждение, которое можно подавить с помощью переменной окружения ```COMPOSE_IGNORE_ORPHANS=True```. Однако, в проде это может выйти боком.

## Визуализация метрик: Grafana

Добавим в docker-compose-monitoring.yml:
```
...
  grafana:
    container_name: grafana
    image: grafana/grafana:5.0.0
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    networks:
      back_net:
        aliases:
        - grafana

volumes:
  ...
  grafana_data: 
```

Как водится, нужно открыть порт 3000:
```
gcloud compute firewall-rules create tcp3000 \
 --allow tcp:3000 \
 --target-tags=docker-machine \
 --description="Allow port 3000 connections (grafana)" \
 --direction=INGRESS
```

Запустим контейнер и войдем на веб-интерфейс grafana, авторизуемся под указанными в секции environment логином и паролем. 
Добавим источинки данных (add data source).  Тип и параметры подключения:
  * Name: Prometheus Server
  * Type: Prometheus
  * URL: http://prometheus:9090
  * Access: Proxy

### Импорт дашборда (шаблона)
Скачаем дашборд с сайта [grafana](https://grafana.com/grafana/dashboards), разместим его в файле ```monitoring/grafana/dashboards/DockerMonitoring.json```
Выполним импорт дашборда из файла (можно просто указать его id на grafana.com, если не нужно кастомизировать), укажем добавленный ранее источни данных (prometheus).

### Создание дашборда
Построим простой график изменения счетчика HTTP-запросов по времени:
  * Выберем источник данных (prometheus), в поле запроса введем название метрики: ```ui_request_count```
  * Уменьшим временной интервал, настроим автообновление данных: Time range ```From: now-15m```, ```To: now```, ```Refreshing every: 10s``` (пиктограмма с часами в правом верхнем углу).
  * Настроим заголовок и описание в секции general

### Отображение ошибочных запросов (4XX, 5XX)
   * Создадим график, укажем выражение ```rate(ui_request_count{http_status=~"^[45].*"}[1m])``` 
     Будем использовать функцию _rate()_, чтобы посмотреть не просто значение счетчика за весь период наблюдения, но и скорость увеличения данной величины за промежуток времени (возьмем, к примеру 1-минутный интервал, чтобы график был хорошо видим)
     Для того, чтобы на графике отобразились данные, перейдем на несуществующую страницу ui

### Верисонирование дашбордов
В свойствах созданного дашборда (пункт settings в левом меню) можно посмотреть на список версий и при необходимости откатиться. Поэтому необходимо при сохранении заполнять description изменения.

### Правка дашборда (самостоятельно)
Первый график, который мы сделали просто по ui_request_count не отображает никакой полезной информации, т.к. тип метрики count, и она просто растет. 
Задание: Используйте для первого графика (UI http requests) функцию rate аналогично второму графику (Rate of UI HTTP Requests with Error)
```rate(ui_request_count{http_status=~"^[23].*"}[1m])```

### Гистограмма
Графический способ представления распределения вероятностей некоторой случайной величины на заданном промежутке значений. 
Для построения гистограммы берется интервал значений, который может принимать измеряемая величина и разбивается на промежутки (обычно одинаковой величины).
Данные промежутки помечаются на горизонтальной оси X. Затем над каждым интервалом рисуется прямоугольник, высота которого соответствует числу измерений величины, попадающих в данный интервал.

В Prometheus есть тип метрик histogram (ГИДЕ??? есть опция stacked, но она рисует какую то радугу. Ну, полрадуги). 
Посмотрим информацию по времени обработки запроса приходящих на главную страницу приложения:
```ui_request_latency_seconds_bucket{path="/"}```

Данный тип метрик в качестве своего значение отдает ряд распределения измеряемой величины в заданном интервале значений. 
Мы используем данный тип метрики для измерения времени обработки HTTP запроса нашим приложением:
```ui_request_response_time_bucket{path="/"}```

!!! В мордочке прометея граф рисуется повернутым (в сравнении с рисунками на слайде), либо увеличивающимся. Вероятно, гистограммы рисуются где то в другом месте.


### Процентиль 
Числовое значение в наборе значений. Все числа в наборе меньше процентиля, попадают в границы заданного процента значений от всего числа значений в наборе
*Хрестоматия:* В классе 20 учеников. Валя занимает 4-е место по росту в классе. 20-4=16 >> 16/20*100=80% Тогда рост Вали (180 см) является 80-м процентилем. Это означает, что 80 % учеников имеют рост менее 180 см.

Вычислим 95-й процентиль для выборки времени обработки запросов,
чтобы посмотреть какое значение является максимальной границей для большинства (95%) запросов. Для этого воспользуемся встроенной функцией histogram_quantile():
```histogram_quantile(0.95, sum(rate(ui_request_latency_seconds_bucket[5m])) by (le))```
Сохраним настройки дашборда в файл: ```monitoring/grafana/dashboards/UI_Service_Monitoring.json```

## М2 Сбор метрик бизнес-логики
Мониторинг бизнес-логики
Ранее были добавлены счетчики количества постов и комментариев
  * post_count
  * comment_count
Построим график скорости роста значения счетчика за последний час, используя функцию rate(). Это позволит получать информацию об активности пользователей приложения.

## Алертинг

Определим несколько правил, в которых зададим условия состояний наблюдаемых систем, при которых мы должны получать
оповещения, т.к. заданные условия могут привести к недоступности или неправильной работе нашего приложения.
_! В Grafana тоже есть alerting. Но по функционалу он уступает Alertmanager в Prometheus._

Создадим каталог ```monitoring/alertmanager``` с Dockerfile:
```
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/
```

Для тестирования создал в workspace devops-team-otus.slack.com приложение guildin-test-slack.
В настройках включил Incoming Webhooks и добавил новый: 
```curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' https://hooks.slack.com/services/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```



config.yml:
```
global:
  slack_api_url: 'https://hooks.slack.com/services/публиковать/не/надо'

route:
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#alexander_tikhonov'
```

В docker-compose-monitoring.yml добавлено:
```
...
services:
  alertmanager:
    image: ${USER_NAME}/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - 9093:9093
    networks:
      back_net:
        aliases:
          - alertmanager
...
```

В директории prometheus создадим файл alerts.yml, в котором определим условия алерта, посылаемого Alertmanager-у. 
Мы создадим простой алерт, который будет срабатывать в ситуации, когда одна из наблюдаемых систем (endpoint) недоступна для сбора метрик (в этом случае метрика up с лейблом instance равным имени данного эндпоинта будет равна 0). 
_Выполним запрос по имени метрики up в веб интерфейсе Prometheus, чтобы убедиться, что сейчас все эндпоинты доступны для сбора метрик._

alerts.yml:
```
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```

Dockerfile:
```
...
ADD alerts.yml /etc/prometheus/
```

Добавим информацию о правилах в настройки prometheus.yml:
```
...
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"
...
```

Пересоберем образ прометея (docker build -t guildin/prometheus .) и пересоздадим инфру мониторинга заново.
Алерты можно посмотреть в веб интерфейсе Prometheus.
Остановим сервис post (```docker-compose stop post```) и убедимся в срабатывании алерта:
  * В веб-интерфейсе:
```
Alerts
InstanceDown (1 active)
```
  * В slack:
```
guildin-test-slackAPP 3:28 PM
[FIRING:1] InstanceDown (post:5000 post page)
```
NB! У Alertmanager также есть свой веб интерфейс, доступный на порту 9093, который мы прописали в компоуз файле.
    P.S. Проверить работу вебхуков слака можно обычным curl.

Добавим в makefile результат работы:
```
build_alertmgr:
	cd ${PATH_ALERTMANAGER_SRC} && bash ./docker_build.sh . 
...
push_alertmgr:
	docker push ${USER_NAME}/alertmanager

push_mon1: push_comment push_post push_ui push_prometheus push_exporter_mongo push_exporter_blackbox push_alertmgr
```

Отправим результаты работы на хаб:
```make push_mon1```

## M2 Задания Ж:
Задания со *
  * Если в прошлом ДЗ вы реализовали Makefile, добавьте в него билд и публикацию добавленных в этом ДЗ сервисов;
```ok```
  * В Docker в экспериментальном режиме реализована отдача метрик в формате Prometheus. Добавьте сбор этих метрик в Prometheus. Сравните количество метрик
с Cadvisor. Выберите готовый дашборд или создайте свой для этого источника данных. Выгрузите его в monitoring/grafana/dashboards;
```
docker-user@docker-host:~$ history
  sudo vim /etc/docker/daemon.json
{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
  sudo systemctl restart docker
  ss -lt
  ...
LISTEN     0      128  :::9323  *:*
  ...
```
Несмотря на то, что конфигурация была поправлена, а демон начал слушать соответствующий порт, получить метрики мы пока не можем: 
```
docker-user@docker-host:~$ curl localhost:9323
404 page not found
```
Лезем в [песочницу](https://www.katacoda.com/courses/prometheus/docker-metrics) и вот оно что:
```curl localhost:9323/metrics```

Добавим правило брандмауэра, чтобы посмотреть метрики снаружи:
gcloud compute firewall-rules create docker-metrics-experimental \
 --allow tcp:9323 \
 --target-tags=docker-machine \
 --description="Allow docker-metrics view" \
 --direction=INGRESS

Костыли и грабли: прометею из докера нужно получить доступ к сокету на хостовой машине. Пока указал локальный ip машины, но TODO сделать менее криво.
пытался накрутить счетчик на одну из уникальных метрик демона builder_builds_failed_total{reason="dockerfile_empty_error"}, несколько раз запустив билд с пустым докерфайлом, но счетчик не вырос и стало неинтересно. Какая там графана, если сами счетчики не дергаются?

## Здесь и далее - TODO
  * Для сбора метрик с Docker демона также можно использовать Telegraf от InfluxDB. Добавьте сбор этих метрик в Prometheus. Сравните количество метрик с Cadvisor. Выберите готовый дашборд или создайте свой для этого источника данных. Выгрузите его в monitoring/grafana/dashboards;
  * Придумайте и реализуйте другие алерты, например на 95 процентиль времени ответа UI, который рассмотрен выше; Настройте интеграцию Alertmanager с e-mail
помимо слака;


