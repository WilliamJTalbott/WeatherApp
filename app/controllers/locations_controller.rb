class LocationsController < ApplicationController
  require 'ipaddr'
  require 'httparty'
  require 'json'

  def is_ip_address?(string)
      IPAddr.new(string)
      true
    rescue IPAddr::InvalidAddressError
      false
  end

  def call_postal_api(postal_adr)
    url = 'https://geocode.xyz'

    params = {
        'auth' => '407111560940047568871x75588',
        'locate' => postal_adr,
        'json' => 1
    }

    response = HTTParty.get(url, query: params)
    output = response.body
    return output
  end

  def call_ip_api(ip_adr)
    response = HTTParty.get("https://ipapi.co/#{ip_adr}/json/")
    output = JSON.parse(response.body)
    return output
  end

  def index

    @addresses_data = []

    locations = Location.all

    locations.each_with_index do |location, index|

      data = "not an ip"

      if is_ip_address?(location.address)
        data = call_ip_api(location.address)
      else
        data = call_postal_api(location.address)
      end

      @addresses_data[index] = data

    end
    
  end
end