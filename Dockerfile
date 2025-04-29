FROM ruby:3.3
WORKDIR /app
COPY . .
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb"]
