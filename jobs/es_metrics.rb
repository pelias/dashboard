require 'json'

# Allow specification of an elasticsearch endpoint vian env var.
#   Should take the form of "http://{ip|hostname}:{port}/{index}"
es_endpoint = ENV['ES_ENDPOINT'] || 'http://localhost:9200/pelias'

# es metrics
SCHEDULER.every '1m' do
  url = URI.parse "#{es_endpoint}/_stats?human"
  response = JSON.parse Net::HTTP.get_response(url).body

  store_size = response['indices']['pelias']['primaries']['store']['size']
  send_event('es-store-size', text: store_size)

  index_time = response['indices']['pelias']['primaries']['indexing']['index_time_in_millis']
  index_time_hours = (index_time / 3_600_000.0).round(1).to_s + 'h'
  send_event('es-index-time', text: index_time_hours)

  completion_size = response['indices']['pelias']['primaries']['completion']['size']
  send_event('es-completion-size', text: completion_size)
end

# index rate
count = []
count << { rate: 0, indexed: false }
SCHEDULER.every '10s' do
  url = URI.parse "#{es_endpoint}/_stats/indexing?human"
  response = JSON.parse Net::HTTP.get_response(url).body
  indexed = response['indices']['pelias']['primaries']['indexing']['index_total']

  # avoid huge spike with first data point
  count.last[:indexed] == false ? rate = 0 : rate = (indexed - count.last[:indexed]) / 10

  # don't return a negative indexing rate
  rate < 0 ? rate = 0 : rate

  count.shift
  count << { rate: rate, indexed: indexed }

  send_event('es-index-rate', value: count.last[:rate])
end

# version
SCHEDULER.every '5m' do
  host = URI.split(es_endpoint)[2]
  port = URI.split(es_endpoint)[3]
  port.nil? ? port = 80 : port
  
  version_url = URI.parse "http://#{host}:#{port}/"
  response = JSON.parse Net::HTTP.get_response(version_url).body
  version = response['version']['number']

  send_event('es-version', text: version)
end
