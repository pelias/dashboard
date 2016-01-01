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
