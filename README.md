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


...
токен раннера ygQXv1ZreQwBtdh2xJA9

Выполним на сервере Gitlab CI команду:
```
sudo docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

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
```docker build -t reddit:latest ./docker-monolith```
  * Деплойте контейнер с reddit на созданный для ветки сервер
Постановка задачи:
- Установим докер-машину и прицепим наш докер хост к gcp. Это вообще рисковый шаг, но полет мысли то какой!
- Создадим в branch review скрипт, создающий докер-хост с именем $CI_ENVIRONMENT_SLUG и все такое. Господи, только бы взлетело!



