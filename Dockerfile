FROM ruby:2.6

RUN apt-get update && apt-get install -y \
  unzip \
  nodejs

RUN useradd -m -d /opt/pelias pelias && \
  chown -R pelias:pelias /opt/pelias

USER pelias

ENV WORKDIR /opt/pelias/dashboard
WORKDIR $WORKDIR

# Gems:
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install

ADD . ${WORKDIR}

CMD bundle exec smashing start
