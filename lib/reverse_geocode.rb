require 'net/http'
require 'uri'
require 'json'

class ReverseGeocode
  class GeocodeError < StandardError
    ERRORS = {
      400 => "Bad Request",
      500 => "Server Error",
      601 => "Missing Query or Address",
      602 => "Unknown Address",
      603 => "Unavailable Address",
      604 => "Unknown Directions",
      610 => "Bad Key",
      620 => "Too Many Queries"
    }

    def initialize(error_code)
      super("#{error_code}: #{ERRORS[error_code]}")
    end
  end

  class << self; attr_accessor :api_key; end

  attr_reader :lat, :long
  def initialize(lat, long)
    raise ArgumentError, "Latitude and longitude required" unless lat && long
    @lat, @long = lat, long
  end

  def response
    @response ||= handle_response
  end

  def address
    @address ||= first_placemark/'address'
  end

  def street
    @street ||= first_administrative_area/'Thoroughfare'/'ThoroughfareName'
  end

  def state
    @state ||= first_administrative_area/'AdministrativeAreaName'
  end

  def zip
    @zip ||= first_administrative_area/'PostalCode'/'PostalCodeNumber'
  end

  def city
    @city ||= placemark[1]/'AddressDetails'/'Country'/'AdministrativeArea'/'Locality'/'LocalityName'
  end

  def county
    @county ||= (placemark[3]/'AddressDetails'/'Country'/'AdministrativeArea'/'AddressLine').first
  end

  private

  def first_placemark
    placemark[0]
  end

  def first_administrative_area
    first_placemark/'AddressDetails'/'Country'/'AdministrativeArea'
  end

  def placemark
    (response/"Placemark")
  end

  def reverse_geocode_uri
    URI.parse("http://maps.google.com/maps/geo?ll=#{URI.escape(lat.to_s)},#{URI.escape(long.to_s)}&output=json")
  end

  def parse_json
    body = Net::HTTP.get_response(reverse_geocode_uri).body
    JSON.parse(body)
  end

  def handle_response
    hash = parse_json
    status_code = (hash/'Status'/'code').to_i
    raise GeocodeError, status_code if status_code >= 400
    return hash
  end
end

class Hash
  alias_method :/, :[]
end
