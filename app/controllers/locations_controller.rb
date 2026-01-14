class LocationsController < ApplicationController
  require "ipaddr"
  require "httparty"
  require "json"

  def update_location_data(location)
      if is_address_ip?(location)
        set_ip_data(location)
      else
        set_postal_data(location)
      end
      location.save
  end


  def is_address_ip?(location)
    IPAddr.new(location.address)
    true
  rescue IPAddr::InvalidAddressError
    false
  end

  def set_postal_data(location)
    url = "https://geocode.xyz"

    params = {
        "auth" => "407111560940047568871x75588",
        "locate" => location.address,
        "json" => 1
    }

    response = HTTParty.get(url, query: params)
    output = JSON.parse(response.body)

    location.city = output["city"].to_s
    location.latitude = output["latt"].to_f
    location.longitude = output["longt"].to_f
  end

  def set_ip_data(location)
    response = HTTParty.get("https://ipapi.co/#{location.address}/json/")
    output = JSON.parse(response.body)

    location.city = output["city"].to_s
    location.latitude = output["latitude"].to_f
    location.longitude = output["longitude"].to_f
  end

  def index
    Location.all.each do |location|
      update_location_data(location)
    end
    @addresses_data = Location.all
  end
end
