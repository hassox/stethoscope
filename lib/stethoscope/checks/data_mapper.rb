require 'stethoscope'

# Provides a check for datamapper databases
Stethoscope.check :database, :critical do |response|
  query = "SELECT 1"
  response["query"] = query.inspect
  DataMapper.repository.adapter.execute(query)
  response['Datamapper'] = "OK"
end

