FROM ruby:2.3.7-slim-jessie

WORKDIR /app

# RUN bundle config --global frozen 1
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

RUN cd test/ && ruby all.rb

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "unity.rb"]
