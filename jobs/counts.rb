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
    s = (s / 1000000000000.0).round(1)
    "#{s}" + 'T'
  elsif s >= 1000000000
    s = (s / 1000000000.0).round(1)
    "#{s}" + 'B'
  elsif s >= 1000000
    s = (s / 1000000.0).round(1)
    "#{s}" + 'M'
  elsif s >= 10000
    s = (s / 1000.0).round(1)
    "#{s}" + 'K'
  elsif s >= 1000
    s = (s / 1000.0).round(1)
    "#{s}" + 'K'
  end
end

SCHEDULER.every '30s' do
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
