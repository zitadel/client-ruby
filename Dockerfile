FROM ruby:3.3@sha256:06c1c61f615d408a44d8d6f3a06b1e1f9dd1882aecb91a6a9fc75fe93d051369
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
