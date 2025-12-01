FROM ruby:3.4@sha256:cff944ca9f1398116ca31573b65a9f4e2e71336701f9229cb24a2e023e477a00
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
