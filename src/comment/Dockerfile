FROM ruby:2.3-alpine

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
ENV APP_HOME /app

RUN apk update && apk add build-base && gem install bundler --no-document && rm -rf /var/cache/apk/* 
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

CMD ["puma"]
