require 'CSV'

i = 0
CSV.open('sample-addresses.csv', 'r').each do |row|
  addr = { address1: row[12], city: row[13], state: row[14], zip: row[15] }
  # puts addr
  geocoded_addresses = ArcGISService::GeocodingService.new(addr).geocode
  i += 1
  break if i > 125
end
