FROM ruby:3.4@sha256:4cf7641c6354e8f407afd2dbb0ab1968cd44ac443bd833c16bdf55cc074a3eb8
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
