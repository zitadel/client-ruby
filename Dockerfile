FROM ruby:3.4@sha256:8b541f8279f3e960c74ff31fb8fd523c59d82725c9fb921d504e9078d553c862
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb", "-r", "zitadel_client"]
