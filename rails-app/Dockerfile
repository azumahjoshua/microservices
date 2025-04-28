FROM ruby:3.2
RUN gem install rails -v "~>7.1.0"
WORKDIR /app
COPY . .
RUN bundle install
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]