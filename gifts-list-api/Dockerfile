FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN gem install bundler
RUN mkdir /gifts-list-api
WORKDIR /gifts-list-api
COPY Gemfile /gifts-list-api/Gemfile
COPY Gemfile.lock /gifts-list-api/Gemfile.lock
RUN bundle install
COPY . /gifts-list-api