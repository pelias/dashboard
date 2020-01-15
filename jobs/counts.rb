require 'json'
require_relative 'include.rb'

SCHEDULER.every '30s' do

  # make a list of common layers
  # total is also first to ensure it shows up first
  default_layers = %w(
    total
    address
    venue
    street
    country
    county
    dependency
    disputed
    localadmin
    locality
    macrocounty
    macroregion
    neighbourhood
    region
    postalcode
  )
  layer_counts = Hash.new(value: 0)

  # initialize type counts to 0 for common layers
  default_layers.each do |type|
    layer_counts[type] = { label: type, value: 0 }
  end

  # get total count
  total_url = URI.parse "#{@es_endpoint}#{@es_index}/_count"

  total_response = Net::HTTP.post(total_url, '', { "Content-Type" => "application/json" })

  total_response_body = JSON.parse total_response.body

  layer_counts['total'] = { label: 'total', value: as_val(total_response_body['count']) }

  # aggregation query to get all layer counts
  query = {
    aggs: {
      layers: {
        terms: {
          field: 'layer',
          size: 1000
        }
      }
    },
    size: 0
  }

  # get layer counts by aggregation
  url = URI.parse "#{@es_endpoint}#{@es_index}/_search?request_cache=true"

  response = Net::HTTP.post(url, query.to_json, { "Content-Type" => "application/json" })

  response_body = JSON.parse response.body

  layer_count_results = response_body['aggregations']['layers']['buckets']

  layer_count_results.each do |result|
    layer = result['key']
    count = as_val(result['doc_count'])
    layer_counts[layer] = { label: layer, value: count }
  end

  send_event('types-counts', items: layer_counts.values)
end
