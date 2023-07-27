require 'faraday'

# Allow specification of an elasticsearch endpoint via env var
#   Should take the form of "http://{ip|hostname}:{port}/"
@es_endpoint = ENV['ES_ENDPOINT'] || 'http://localhost:9200/'

@es_client = Faraday.new(@es_endpoint)
@es_client.basic_auth ENV['ES_USERNAME'], ENV['ES_PASSWORD'] if ENV['ES_USERNAME'] || ENV['ES_PASSWORD']