class LocationsController < ApplicationController
  include ActionView::RecordIdentifier
  require "ipaddr"
  require "httparty"
  require "json"

  def update_location_data(location)
      if is_address_ip?(location)
        set_ip_data(location)
      else
        set_postal_data(location)
      end
  end

  def get_weather_data(location)
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{location.latitude}&longitude=#{location.longitude}&daily=temperature_2m_max,temperature_2m_min&timezone=auto&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch"
    response = HTTParty.get(url)
    JSON.parse(response.body)

    weather_data = []

    response["daily"]["time"].each_with_index do |date, index|
      weather_data << {
      date: date,
      day_initial: Date.parse(date).strftime("%a")[0],
      high_temp: response["daily"]["temperature_2m_max"][index],
      low_temp: response["daily"]["temperature_2m_min"][index]
    }
    end

  weather_data
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
    begin
      output = JSON.parse(response.body)

      if output["error"]
        raise "ApiError"
      end

      location.city = output["standard"]["city"].to_s
      location.latitude = output["latt"].to_f
      location.longitude = output["longt"].to_f

    rescue
      puts("ADDRESS API did not return JSON")
      false
    end
  end

  def set_ip_data(location)
    response = HTTParty.get("https://ipapi.co/#{location.address}/json/")

    begin
      output = JSON.parse(response.body)

      if output["error"]
        raise "ApiError"
      end

      location.city = output["city"].to_s
      location.latitude = output["latitude"].to_f
      location.longitude = output["longitude"].to_f
      true

    rescue
      puts("IP API did not return JSON")
      false
    end
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

    if @location.nil?
      user_ip = request.remote_ip
      @location = Location.new(address: user_ip)

      if update_location_data(@location) and @location.save
        puts(@location.address)
        puts(@location.city)
        puts(@location.latitude)
        puts(@location.longitude)

      else
        puts("default")
        @location.city = "New York"
        @location.latitude = 40.7128
        @location.longitude = -74.0060
      end
    end

    @weather_data = get_weather_data(@location)
    @locations = Location.all
  end

  def create
    begin
      @location = Location.new(location_params)
      update_location_data(@location)
      # puts(@location.address)
      # puts(@location.city)
      # puts(@location.longitude)
      # puts(@location.latitude)

      if @location.save
      render turbo_stream: turbo_stream.prepend(
        "locations_container",
        partial: "sidebar_item",
        locals: {
          location: @location,
          current_location: nil
        }
      )
        # else
        #   puts("NOT VALID LOCATION?")
      end

    rescue
      puts "Invalid Address"
    end
  end

  def location_params
    params.permit(:address)
  end

  def delete
    @location = Location.find_by(city: params[:city])
    @location.destroy
    render turbo_stream: turbo_stream.remove(dom_id(@location))
  end
end
