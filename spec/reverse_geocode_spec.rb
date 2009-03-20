require File.dirname(__FILE__) + '/spec_helper'

describe "ReverseGeocode" do
  before do
    @attrs = {
      :lat => 30.009897,
      :long => -81.387655,
      :address => "439-499 La Travesia Flora, FL 32095, USA",
      :street => "439-499 La Travesia Flora",
      :state => "FL",
      :city => "St Augustine",
      :zip => "32095",
      :county => "St Johns"
    }

    @response = {"Status"=>{"code"=>200, "request"=>"geocode"},
     "name"=>"30.009897,-81.387655",
     "Placemark"=>
      [{"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"Thoroughfare"=>{"ThoroughfareName"=>@attrs[:street]},
              "PostalCode"=>{"PostalCodeNumber"=>@attrs[:zip]},
              "AdministrativeAreaName"=>@attrs[:state]},
            "CountryName"=>"USA",
            "CountryNameCode"=>"US"},
          "Accuracy"=>8},
        "id"=>"p1",
        "ExtendedData"=>
         {"LatLonBox"=>
           {"east"=>-81.3845068,
            "south"=>30.0067498,
            "west"=>-81.390802,
            "north"=>30.013045}},
        "Point"=>{"coordinates"=>[-81.3876544, 30.0098974, 0]},
        "address"=> @attrs[:address]},
       {"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"Locality"=>
               {"LocalityName"=>@attrs[:city],
                "PostalCode"=>{"PostalCodeNumber"=>@attrs[:zip]}},
              "AdministrativeAreaName"=>"FL"},
            "CountryName"=>"USA",
            "CountryNameCode"=>"US"},
          "Accuracy"=>5},
        "id"=>"p2",
        "ExtendedData"=>
         {"LatLonBox"=>
           {"east"=>-81.313069,
            "south"=>29.929597,
            "west"=>-81.498143,
            "north"=>30.086469}},
        "Point"=>{"coordinates"=>[-81.4059186, 29.9934528, 0]},
        "address"=>"St Augustine, FL 32095, USA"},
       {"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"AddressLine"=>["St Augustine"], "AdministrativeAreaName"=>"FL"},
            "CountryName"=>"USA",
            "CountryNameCode"=>"US"},
          "Accuracy"=>4},
        "id"=>"p3",
        "ExtendedData"=>
         {"LatLonBox"=>
           {"east"=>-81.194405,
            "south"=>29.767845,
            "west"=>-81.63343,
            "north"=>30.18062}},
        "Point"=>{"coordinates"=>[-81.3839326, 30.0149544, 0]},
        "address"=>"St Augustine, Florida, USA"},
       {"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>
             {"AddressLine"=>[@attrs[:county]], "AdministrativeAreaName"=>"FL"},
            "CountryName"=>"USA",
            "CountryNameCode"=>"US"},
          "Accuracy"=>3},
        "id"=>"p4",
        "ExtendedData"=>
         {"LatLonBox"=>
           {"east"=>-81.150818,
            "south"=>29.622428,
            "west"=>-81.69039,
            "north"=>30.253036}},
        "Point"=>{"coordinates"=>[-81.4278984, 29.9719419, 0]},
        "address"=>"St Johns, Florida, USA"},
       {"AddressDetails"=>
         {"Country"=>
           {"AdministrativeArea"=>{"AdministrativeAreaName"=>"FL"},
            "CountryName"=>"USA",
            "CountryNameCode"=>"US"},
          "Accuracy"=>2},
        "id"=>"p5",
        "ExtendedData"=>
         {"LatLonBox"=>
           {"east"=>-79.974307,
            "south"=>24.396308,
            "west"=>-87.634643,
            "north"=>31.001056}},
        "Point"=>{"coordinates"=>[-81.5157535, 27.6648274, 0]},
        "address"=>"Florida, USA"},
       {"AddressDetails"=>
         {"Country"=>{"CountryName"=>"USA", "CountryNameCode"=>"US"},
          "Accuracy"=>1},
        "id"=>"p6",
        "ExtendedData"=>
         {"LatLonBox"=>
           {"east"=>-65.168504,
            "south"=>17.83151,
            "west"=>172.347848,
            "north"=>71.434357}},
        "Point"=>{"coordinates"=>[-95.712891, 37.09024, 0]},
        "address"=>"United States"}]}

    Net::HTTP.stub!(:get_response)
    @reverse_geocode = ReverseGeocode.new(@attrs[:lat], @attrs[:long])
    @reverse_geocode.stub!(:parse_json).and_return(@response)
  end

  %w( lat long address street state city zip county ).each do |attr|
    describe "##{attr}" do
      it {@reverse_geocode.send(attr).should == @attrs[attr.to_sym]}
    end
  end

  describe '#placemark_by_accuracy' do
    it 'should return the placemark with the given accuracy' do
      (@reverse_geocode.send(:placemark_by_accuracy, 3)/'AddressDetails'/'Accuracy').to_i.should == 3

    end
  end

  describe "without a latitude or longitude" do
    it "should raise an ArgumentError" do
      lambda { ReverseGeocode.new(nil, 1) }.should raise_error(ArgumentError)
      lambda { ReverseGeocode.new(1, nil) }.should raise_error(ArgumentError)
    end
  end

  describe "when the response is a" do
    def error_json(code)
      {"Status"=>{"code"=>code, "request"=>"geocode"}, "name"=>""}
    end

    errors = {
      400 => "Bad Request",
      500 => "Server Error",
      601 => "Missing Query or Address",
      602 => "Unknown Address",
      603 => "Unavailable Address",
      604 => "Unknown Directions",
      610 => "Bad Key",
      620 => "Too Many Queries"
    }

    errors.each do |code, message|
      describe code.to_s do
        before do
          @reverse_geocode.stub!(:parse_json).and_return(error_json(code))
        end

        it "should raise a GeocodeError with #{message}" do
          lambda {
            @reverse_geocode.send(:handle_response)
          }.should raise_error(ReverseGeocode::GeocodeError, "#{code}: #{message}")
        end
      end
    end
  end
end
