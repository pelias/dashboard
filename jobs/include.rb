@es_endpoint = ENV['ES_ENDPOINT'] || 'http://localhost:9200/'

# determine if a given index name is actually an alias
# and if so, return the true index name
def resolve_alias(index_name)
  alias_response = Net::HTTP.get_response(URI.parse("#{@es_endpoint}_alias/#{index_name}"))
  puts alias_response.body
  puts alias_response.code

  if alias_response.code != "200"
    index_name
  else
    parsed_response = JSON.parse(alias_response.body)
    puts parsed_response
    actual_index = parsed_response.keys[0]
    puts "#{index_name} is an alias to #{actual_index}"
    actual_index
  end
end

# Allow specification of an elasticsearch endpoint via env var.
#   Should take the form of "http://{ip|hostname}:{port}/"
es_index = ENV['ES_INDEX'] || 'pelias'

@es_index = resolve_alias(es_index)

# expected doc count
@expected_doc_count = ENV['EXPECTED_DOC_COUNT'] || nil

# convert for the counts list
def as_val(s)
  if s < 1_000
    s
  elsif s >= 1_000_000_000_000
    (s / 1_000_000_000_000.0).round(1).to_s + 'T'
  elsif s >= 1_000_000_000
    (s / 1_000_000_000.0).round(1).to_s + 'B'
  elsif s >= 1_000_000
    (s / 1_000_000.0).round(1).to_s + 'M'
  elsif s >= 1_000
    (s / 1_000.0).round(1).to_s + 'K'
  end
end
