require 'json'
require_relative 'include.rb'

SCHEDULER.every '30s' do
  types = %w(
    geoname
    admin0
    admin1
    admin2
    local_admin
    locality
    neighborhood
    openaddresses
    osmnode
    osmaddress
    osmway
  )
  types_counts = Hash.new(value: 0)

  # get total
  total_url = URI.parse "#{@es_endpoint}/_stats/docs"
  total_response = JSON.parse Net::HTTP.get_response(total_url).body
  total_count = as_val(total_response['indices']['pelias']['primaries']['docs']['count'])
  types_counts['total'] = { label: 'total', value: total_count }

  # get types
  types.each do |t|
    url = URI.parse "#{@es_endpoint}/#{t}/_count"
    response = JSON.parse Net::HTTP.get_response(url).body
    count = as_val(response['count'])
    types_counts[t] = { label: t, value: count }
  end
  send_event('types-counts', items: types_counts.values)
end
