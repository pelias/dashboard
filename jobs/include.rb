# Allow specification of an elasticsearch endpoint via env var.
#   Should take the form of "http://{ip|hostname}:{port}/{index}"
@es_endpoint = ENV['ES_ENDPOINT'] || 'http://localhost:9200/pelias'
@es_index = URI.split(@es_endpoint)[5].split('/').last

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
