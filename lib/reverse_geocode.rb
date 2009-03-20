require 'net/http'
require 'uri'
require 'json'

# ReverseGeocode provides an simple API for accessing reverse geocode data for
# a given geocode using the google maps geocoding API.
#
# Examples:
#   ReverseGeocode.new(30.0098974, -81.3876544).city # => "St Augustine"
class ReverseGeocode
  GOOGLE_URI = "http://maps.google.com/maps/geo"

  # Used to raise Google API errors
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
      super("#{error_code}: #{ERRORS[error_code] || 'Unknown Error'}")
    end
  end

  class << self; attr_accessor :api_key; end

  # Creates a new reverse geocode object.
  def initialize(lat, long)
    raise ArgumentError, "Latitude and longitude required" unless lat && long
    @lat, @long = lat, long
  end
  attr_reader :lat, :long

  # The raw response hash from the reverse geocode request
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
    @city ||= (placemark_by_accuracy(4)/'AddressDetails'/'Country'/'AdministrativeArea'/'AddressLine').first
  end

  def county
    @county ||= (placemark_by_accuracy(3)/'AddressDetails'/'Country'/'AdministrativeArea'/'AddressLine').first
  end

  private

  def first_placemark
    placemark_by_accuracy(8)
  end

  def first_administrative_area
    first_placemark/'AddressDetails'/'Country'/'AdministrativeArea'
  end

  def placemark
    (response/"Placemark")
  end

  def placemark_by_accuracy(accuracy)
    placemark.detect { |x| (x/'AddressDetails'/'Accuracy').to_i == accuracy.to_i }
  end

  def reverse_geocode_uri
    URI.parse("#{GOOGLE_URI}?ll=#{URI.escape(lat.to_s)},#{URI.escape(long.to_s)}")
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

# Hash.[] is aliased to '/' to provide xpath-like access into the response
# hash
class Hash
  alias_method :/, :[]
end

class NilClass
  # Raises a more useful error when nil#/ is called.
  def /(other)
    raise ArgumentError, "Unknown method '/' called on nil with #{other.inspect}. Maybe you were looking for a Hash?"
  end
end
