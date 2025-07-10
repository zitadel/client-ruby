FROM ruby:3.4@sha256:f7ab76e2c36ab406ebc36aeba20624b26a8fae7c2998acabbe9662e2a73f00f3
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
