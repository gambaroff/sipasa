require 'sinatra/base'

module Sinatra
  module ResponseFormat
    def format_response(data, accept)
      accept.each do |type|
        return data.to_json if type.downcase.eql? 'application/json'
        return data.to_csv  if type.downcase.eql? 'text/csv'
        return data.to_json
      end
    end
  end
  helpers ResponseFormat
end
