require 'json'

# counts
%w(geoname openaddresses osmnode osmway osmaddress admin0 admin1 admin2 local_admin locality neighborhood).each do |t|
  SCHEDULER.every '10s' do
    url = URI.parse "http://localhost:9200/pelias/#{t}/_count"
    response = JSON::parse Net::HTTP.get_response(url).body
    count = response['count']
    send_event("#{t}-count", { current: count })
  end
end

# es metrics
SCHEDULER.every '10s' do
  url = URI.parse "http://localhost:9200/pelias/_stats/store?human"
  response = JSON::parse Net::HTTP.get_response(url).body
  store_size = response['indices']['pelias']['primaries']['store']['size']
  send_event('store-size', { text: store_size })
end

SCHEDULER.every '10s' do
  url = URI.parse "http://localhost:9200/pelias/_stats/completion?human"
  response = JSON::parse Net::HTTP.get_response(url).body
  completion_size = response['indices']['pelias']['primaries']['completion']['size']
  send_event('completion-size', { text: completion_size })
end
