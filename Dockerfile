FROM ruby:3.4@sha256:16c69ea506c1ef96474926e3e13fd7444d3964db2f783595a6da9389b8cec301
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
