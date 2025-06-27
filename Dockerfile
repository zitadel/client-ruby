FROM ruby:3.4@sha256:e08e271f196cf578ea73e00baa572d76d2dc5a7d5c2bd1151f90a364c9cc4a4f
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
