FROM alpine:3.10.3

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

RUN apk add --no-cache --virtual .build-deps build-base \
    && apk add ruby-full ruby-dev \
    && gem install bundler -v 1.17.2 --no-ri --no-rdoc \
    && gem install bson_ext -v '1.12.5' --no-ri --no-rdoc \
    && gem install thrift -v '0.9.3.0' --no-ri --no-rdoc \
    && gem install puma -v '3.12.0' --no-ri --no-rdoc 

RUN bundle install
ADD . $APP_HOME

CMD ["puma"]
