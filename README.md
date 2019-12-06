# guildin_microservices

guildin microservices repository

# Курс DevOps 2019-08. Бортовой журнал. Часть 2. Microservices 
Задания со звездочкой отмечаются в журнале литерой *Ж*. Во-первых, символ _астериск_ занят, а во-вторых это немного символично. Самую малось, разумеется.


| [Docker-2](#docker-2) | [Docker GCE](#docker-gce) | [D2 Ж](#d2-ж) | [D2 Задание Ж infra](#d2-задание-ж-infra) |
| --- | --- | --- | --- |
| [Docker-3](#docker-3) | [Docker GCE](#docker-gce) | [D3 Задание Ж](#d3-задание-ж) | [D2 Задание Ж infra](#d2-задание-ж-infra) |
| --- | --- | --- | --- |

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
• docker-machine create <имя>. - создание машины
• eval $(docker-machine env <имя>) - Переключение между машинами
• eval $(docker-machine env --unset). Переключение на локальный докер
• docker-machine rm <имя> - Удаление

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
  * docker logs reddit -f
  * docker exec -it reddit bash
\ ps aux
\ killall5 1
  * docker start reddit
  * docker stop reddit && docker rm reddit
  * docker run --name reddit --rm -it <your-login>/otus-reddit:1.0 bash
\ ps aux
\ exit

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

• Поднятие инстансов с помощью Terraform, их количество задается переменной;
• Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
• Шаблон пакера, который делает образ с уже установленным Docker;

Формулировка задачи
1. Запилить образ пакером, т.к. терраформ сам будет долго-долго. из образа ubuntu1604 (раз уж везде он) плейбуком packer_docker.yml раскатать докер-машину (docker-machine ни при чем).
2. Динамический инвентори (возьмем старый) + плейбук для запуска образа приложения. Режьте ножом, пропущу установку докера, т.к. см. пункт 1
3. Развертывание 2х (или более, но будем экономить!) машин через терраформ.

## before you begin
скопируем файл .gitignore из infra репозитория. Безопасность должна быть безопасной )))

## Выпечка образа.
Все уже ~украдено~ запилено до нас. Сопрем плейбук [отсюда](https://gist.github.com/rbq/886587980894e98b23d0eee2a1d84933) (в девичестве docker.yaml, вообще не смешно пытаться делать его ручками):
Конечный файл infra/ansible/packer_docker.yml
С первого раза, конечно, не взлетело, но become: yes творит чудеса

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

