FROM python:3.6.0-alpine

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

WORKDIR /app
ADD . /app

RUN apk add --no-cache --virtual .build-deps build-base \
  && pip install -r /app/requirements.txt \
  && apk del .build-deps

ENTRYPOINT ["python3", "post_app.py"]
