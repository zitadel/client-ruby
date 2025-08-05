FROM ruby:3.4@sha256:04121e637d449ec6a93b4f4d05eef7bd55be4ffb04391127cab0999676c2de47
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
