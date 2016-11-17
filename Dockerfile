FROM ruby:2.3

RUN apt-get update && apt-get install -y \
  unzip \
  nodejs

RUN useradd -m -d /opt/pelias-dashboard pelias && \
  chown -R pelias:pelias /opt/pelias-dashboard

USER pelias

RUN cd /tmp && \
  curl -L https://github.com/pelias/pelias-dashboard/archive/master.zip > master.zip && \
  unzip master.zip -d /tmp && \
  rm -f /tmp/master.zip && \
  mv /tmp/pelias-dashboard-master/* /opt/pelias-dashboard

RUN gem install bundler

WORKDIR /opt/pelias-dashboard
RUN bundle install
CMD dashing start
