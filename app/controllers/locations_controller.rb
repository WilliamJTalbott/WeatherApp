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

  def get_weather_data(location)
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{location.latitude}&longitude=#{location.longitude}&daily=temperature_2m_max,temperature_2m_min&timezone=auto&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch"
    response = HTTParty.get(url)
    JSON.parse(response.body)
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

  # def index
  #   @weather_array = {}

  #   # Location.all.each do |location|
  #   #   update_location_data(location)
  #   #   weather_json = get_weather_data(location)
  #   #   @weather_array[location.id] = weather_json
  #   # end

  #   @addresses = Location.all
  # end

  def show
    if params[:city]
      @location = Location.find_by(city: params[:city])
    else
      @location = Location.first
    end

    @locations = Location.all
  end
end
