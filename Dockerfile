FROM ruby:3.4@sha256:370e6be29a1cecbf44993087d2750e7d9e1570fde5b97c74325063b1750d11d0
WORKDIR /app
COPY . .
RUN rm -f *.gem
RUN gem build *.gemspec
RUN gem install *.gem
RUN ruby -e "require 'zitadel_client'"
CMD ["irb"]
