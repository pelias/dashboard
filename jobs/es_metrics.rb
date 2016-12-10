require 'json'
require_relative 'include.rb'

# percent complete
unless @expected_doc_count.nil?
  expected_doc_count_pretty = as_val(@expected_doc_count.to_i)

  SCHEDULER.every '1m' do
    url = URI.parse "#{@es_endpoint}/_stats/docs"
    response = JSON.parse Net::HTTP.get_response(url).body
    indexed = response['indices'][@es_index]['primaries']['docs']['count']

    percent_complete = ((indexed.to_f / @expected_doc_count.to_f) * 100).to_i
    percent_complete > 100 ? percent_complete = 100 : percent_complete

    send_event('percent-complete', text: "#{percent_complete}% (~#{expected_doc_count_pretty} expected docs)")
  end
end

# es metrics
SCHEDULER.every '1m' do
  url = URI.parse "#{@es_endpoint}/_stats?human"
  response = JSON.parse Net::HTTP.get_response(url).body

  store_size = response['indices'][@es_index]['primaries']['store']['size']
  send_event('es-store-size', text: store_size)

  completion_size = response['indices'][@es_index]['primaries']['completion']['size']
  send_event('es-completion-size', text: completion_size)
end

# index rate
count = []
count << { rate: 0, indexed: false }
SCHEDULER.every '10s' do
  url = URI.parse "#{@es_endpoint}/_stats/indexing?human"
  response = JSON.parse Net::HTTP.get_response(url).body
  indexed = response['indices'][@es_index]['primaries']['indexing']['index_total']

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
  host = URI.split(@es_endpoint)[2]
  port = URI.split(@es_endpoint)[3]
  port.nil? ? port = 80 : port

  version_url = URI.parse "http://#{host}:#{port}/"
  response = JSON.parse Net::HTTP.get_response(version_url).body
  version = response['version']['number']

  send_event('es-version', text: version)
end
