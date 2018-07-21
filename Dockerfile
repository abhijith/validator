FROM ruby:2.3.7-slim-jessie

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

RUN cd test/ && ruby schema_test.rb

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "unity.rb"]
