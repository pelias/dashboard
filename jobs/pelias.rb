require 'json'

# Allow specification of an elasticsearch endpoint vian env var.
#   Should take the form of "http://{ip|hostname}:{port}/{index}"
es_endpoint = ENV['ES_ENDPOINT'] || "http://localhost:9200/pelias"

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
    response = JSON::parse Net::HTTP.get_response(url).body
    count = response['count']
    send_event("#{t}-count", { current: count })
  end
end

# es metrics
SCHEDULER.every '1m' do
  url = URI.parse "#{es_endpoint}/_stats/store?human"
  response = JSON::parse Net::HTTP.get_response(url).body
  store_size = response['indices']['pelias']['primaries']['store']['size']
  send_event('es-store-size', { text: store_size })
end

SCHEDULER.every '1m' do
  url = URI.parse "#{es_endpoint}/_stats/completion?human"
  response = JSON::parse Net::HTTP.get_response(url).body
  completion_size = response['indices']['pelias']['primaries']['completion']['size']
  send_event('es-completion-size', { text: completion_size })
end
