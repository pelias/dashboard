require 'json'

# Allow specification of an elasticsearch endpoint vian env var.
#   Should take the form of "http://{ip|hostname}:{port}/{index}"
es_endpoint = ENV['ES_ENDPOINT'] || 'http://localhost:9200/pelias'

# counts
%w(
  geoname
  openaddresses
  osmnode
  osmway
  osmaddress
  admin0
  admin1
  admin2
  local_admin
  locality
  neighborhood
).each do |t|
  SCHEDULER.every '10s' do
    url = URI.parse "#{es_endpoint}/#{t}/_count"
    response = JSON.parse Net::HTTP.get_response(url).body
    count = response['count']
    send_event("#{t}-count", current: count)
  end
end

# es metrics
SCHEDULER.every '1m' do
  url = URI.parse "#{es_endpoint}/_stats?human"
  response = JSON.parse Net::HTTP.get_response(url).body

  store_size = response['indices']['pelias']['primaries']['store']['size']
  send_event('es-store-size', text: store_size)

  index_time = response['indices']['pelias']['primaries']['indexing']['index_time']
  send_event('es-index-time', text: index_time)

  doc_count  = response['indices']['pelias']['primaries']['docs']['count']
  send_event('es-doc-count', current: doc_count)

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
  if count.last[:indexed] == false
    rate = 0
  else
    rate = (indexed - count.last[:indexed]) / 10
  end

  count.shift
  count << { rate: rate, indexed: indexed }

  send_event('es-index-rate', value: count.last[:rate])
end
