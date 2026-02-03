require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @weather_data = [
      {
        date: "2006-05-11",
        day_initial: "S",
        high_temp: 35.2,
        low_temp: 28.4
      },
      {
        date: "2006-05-11",
        day_initial: "M",
        high_temp: 35.2,
        low_temp: 28.4
      },
      {
        date: "2006-05-11",
        day_initial: "T",
        high_temp: 35.2,
        low_temp: 28.4
      },
      {
        date: "2006-05-11",
        day_initial: "W",
        high_temp: 35.2,
        low_temp: 28.4
      },
      {
        date: "2006-05-11",
        day_initial: "T",
        high_temp: 35.2,
        low_temp: 28.4
      },
      {
        date: "2006-05-11",
        day_initial: "F",
        high_temp: 35.2,
        low_temp: 28.4
      },
      {
        date: "2006-05-11",
        day_initial: "S",
        high_temp: 35.2,
        low_temp: 28.4
      }
    ]

    LocationsController.any_instance.stubs(:get_weather_data).returns(@weather_data)
  end

  test "should get root" do
    get root_url
    assert_response :success
  end

  test "should get valid forcast for location" do
    get location_url(city: "Chicago")
    assert_response :success
  end

  test "should get coords from IP" do
    location = Location.new(address: "8.8.8.8")
    controller = LocationsController.new

    body = {
      "city" => "Mountain View",
      "latitude" => 37.386,
      "longitude" => -122.084
    }.to_json

    response = stub(body: body)
    HTTParty.stubs(:get).returns(response)

    controller.set_ip_data(location)

    assert_equal("Mountain View", location.city)
    assert_equal(37.386, location.latitude)
    assert_equal(-122.084, location.longitude)
  end
end
