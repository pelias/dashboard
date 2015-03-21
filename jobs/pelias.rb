require 'json'

# Allow specification of an elasticsearch endpoint vian env var.
#   Should take the form of "http://{ip|hostname}:{port}/{index}"
es_endpoint = ENV['ES_ENDPOINT'] || 'http://localhost:9200/pelias'

# convert for the counts list
def as_val(s)
  s.to_f
  if s < 1000
    s
  elsif s >= 1000000000000
    s = (s / 1000000000000).round
    "#{s}" + 'T'
  elsif s >= 1000000000
    s = (s / 1000000000).round
    "#{s}" + 'B'
  elsif s >= 1000000
    s = (s / 1000000.0).round(1)
    "#{s}" + 'M'
  elsif s >= 10000
    s = (s / 1000.0).round(1)
    "#{s}" + 'k'
  elsif s >= 1000
    s = (s / 1000.0).round(1)
    "#{s}" + 'K'
  end
end

SCHEDULER.every '10s' do
  types = %w(geoname admin0 admin1 admin2 local_admin locality neighborhood openaddresses osmnode osmaddress osmway)
  types_counts = Hash.new({ value: 0 })
    
  types.each do |t|
    url = URI.parse "#{es_endpoint}/#{t}/_count"
    response = JSON.parse Net::HTTP.get_response(url).body
    count = as_val(response['count'])
    types_counts[t] = { label: t, value: count }
  end
  send_event('types-counts', { items: types_counts.values })
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
  count.last[:indexed] == false ? rate = 0 : rate = (indexed - count.last[:indexed]) / 10

  count.shift
  count << { rate: rate, indexed: indexed }

  send_event('es-index-rate', value: count.last[:rate])
end
