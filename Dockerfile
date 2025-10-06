FROM ruby:3.4@sha256:2de78cfbe28d99ee29c7a6b6d313617619d7fce68ed22337609f31a50cffc407
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
