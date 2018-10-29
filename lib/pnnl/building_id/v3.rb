# frozen_string_literal: true

require "plus_codes"
require "plus_codes/code_area"
require "plus_codes/open_location_code"
require "pnnl/building_id/code_area"

module PNNL
  module BuildingId
    module V3
      # The separator for OLC codes in a UBID code.
      SEPARATOR_ = "-"

      # Format string for UBID codes.
      FORMAT_STRING_ = "%s-%.0f-%.0f-%.0f-%.0f"

      # Regular expression for UBID codes.
      RE_PATTERN_ = Regexp.new([
        "^",
        "([#{Regexp.quote(PlusCodes::CODE_ALPHABET)}]{4,8}#{Regexp.quote(PlusCodes::SEPARATOR)}[#{Regexp.quote(PlusCodes::CODE_ALPHABET)}]*)",
        "#{Regexp.quote(SEPARATOR_)}",
        "(0|[1-9][0-9]*)",
        "#{Regexp.quote(SEPARATOR_)}",
        "(0|[1-9][0-9]*)",
        "#{Regexp.quote(SEPARATOR_)}",
        "(0|[1-9][0-9]*)",
        "#{Regexp.quote(SEPARATOR_)}",
        "(0|[1-9][0-9]*)",
        "$",
      ].join)

      # The first group of a UBID code is the OLC for the geometric center of mass
      # (i.e., centroid) of the building footprint.
      RE_GROUP_OPENLOCATIONCODE_ = 1

      # The second group of the UBID code is the Chebyshev distance in OLC grid units
      # from the OLC for the centroid of the building footprint to the northern extent
      # of the OLC bounding box for the building footprint.
      RE_GROUP_NORTH_ = 2

      # The third group of the UBID code is the Chebyshev distance in OLC grid units
      # from the OLC for the centroid of the building footprint to the eastern extent
      # of the OLC bounding box for the building footprint.
      RE_GROUP_EAST_ = 3

      # The fourth group of the UBID code is the Chebyshev distance in OLC grid units
      # from the OLC for the centroid of the building footprint to the southern extent
      # of the OLC bounding box for the building footprint.
      RE_GROUP_SOUTH_ = 4

      # The fifth group of the UBID code is the Chebyshev distance in OLC grid units
      # from the OLC for the centroid of the building footprint to the western extent
      # of the OLC bounding box for the building footprint.
      RE_GROUP_WEST_ = 5

      # Returns the UBID code area for the given UBID code.
      #
      # @param code [String] the UBID code
      # @return [PNNL::BuildingId::CodeArea] The UBID code area.
      # @raise [ArgumentError] if the UBID code is invalid or if the OLC for the centroid of the building footprint is invalid
      def self.decode(code)
        if !(md = RE_PATTERN_.match(code)).nil?
          # Extract the OLC for the centroid of the building footprint.
          centroid_openlocationcode = md[RE_GROUP_OPENLOCATIONCODE_]

          # Decode the OLC for the centroid of the building footprint.
          centroid_openlocationcode_CodeArea = open_location_code.decode(centroid_openlocationcode)

          # Calculate the size of the OLC for the centroid of the building footprint
          # in decimal degree units.
          height = centroid_openlocationcode_CodeArea.north_latitude - centroid_openlocationcode_CodeArea.south_latitude
          width = centroid_openlocationcode_CodeArea.east_longitude - centroid_openlocationcode_CodeArea.west_longitude

          # Calculate the size of the OLC bounding box for the building footprint,
          # assuming that the datum are Chebyshev distances.
          north_latitude = centroid_openlocationcode_CodeArea.north_latitude + (Float(md[RE_GROUP_NORTH_]) * height)
          east_longitude = centroid_openlocationcode_CodeArea.east_longitude + (Float(md[RE_GROUP_EAST_]) * width)
          south_latitude = centroid_openlocationcode_CodeArea.south_latitude - (Float(md[RE_GROUP_SOUTH_]) * height)
          west_longitude = centroid_openlocationcode_CodeArea.west_longitude - (Float(md[RE_GROUP_WEST_]) * width)

          # Construct and return the UBID code area.
          return PNNL::BuildingId::CodeArea.new(
            centroid_openlocationcode_CodeArea,
            centroid_openlocationcode.length - PlusCodes::SEPARATOR.length,
            north_latitude,
            south_latitude,
            east_longitude,
            west_longitude
          )
        else
          raise ArgumentError.new('Invalid UBID')
        end
      end

      # Returns the UBID code for the given coordinates.
      #
      # @param latitude_lo [Float] the latitude in decimal degrees of the southwest corner of the minimal bounding box for the building footprint
      # @param longitude_lo [Float] the longitude in decimal degrees of the southwest corner of the minimal bounding box for the building footprint
      # @param latitude_hi [Float] the latitude in decimal degrees of the northeast corner of the minimal bounding box for the building footprint
      # @param longitude_hi [Float] the longitude in decimal degrees of the northeast corner of the minimal bounding box for the building footprint
      # @param latitudeCenter [Float] the latitude in decimal degrees of the centroid of the building footprint
      # @param longitudeCenter [Float] the longitude in decimal degrees of the centroid of the building footprint
      # @param options [Hash]
      # @option options [Integer] :codeLength (`PlusCodes::PAIR_CODE_LENGTH`) the OLC code length (not including the separator)
      # @return [String] The UBID code.
      # @raise [ArgumentError] if the OLC for the centroid of the building footprint cannot be encoded (e.g., invalid code length)
      def self.encode(latitude_lo, longitude_lo, latitude_hi, longitude_hi, latitudeCenter, longitudeCenter, options = {})
        codeLength = options[:codeLength] || PlusCodes::PAIR_CODE_LENGTH

        # Encode the OLCs for the northeast and southwest corners of the minimal
        # bounding box for the building footprint.
        northeast_openlocationcode = open_location_code.encode(latitude_hi, longitude_hi, codeLength)
        southwest_openlocationcode = open_location_code.encode(latitude_lo, longitude_lo, codeLength)

        # Encode the OLC for the centroid of the building footprint.
        centroid_openlocationcode = open_location_code.encode(latitudeCenter, longitudeCenter, codeLength)

        # Decode the OLCs for the northeast and southwest corners of the minimal
        # bounding box for the building footprint.
        northeast_openlocationcode_CodeArea = open_location_code.decode(northeast_openlocationcode)
        southwest_openlocationcode_CodeArea = open_location_code.decode(southwest_openlocationcode)

        # Decode the OLC for the centroid of the building footprint.
        centroid_openlocationcode_CodeArea = open_location_code.decode(centroid_openlocationcode)

        # Calculate the size of the OLC for the centroid of the building footprint
        # in decimal degree units.
        height = centroid_openlocationcode_CodeArea.north_latitude - centroid_openlocationcode_CodeArea.south_latitude
        width = centroid_openlocationcode_CodeArea.east_longitude - centroid_openlocationcode_CodeArea.west_longitude

        # Calculate the Chebyshev distances to the northern, eastern, southern and
        # western of the OLC bounding box for the building footprint.
        delta_north = (northeast_openlocationcode_CodeArea.north_latitude - centroid_openlocationcode_CodeArea.north_latitude) / height
        delta_east = (northeast_openlocationcode_CodeArea.east_longitude - centroid_openlocationcode_CodeArea.east_longitude) / width
        delta_south = (centroid_openlocationcode_CodeArea.south_latitude - southwest_openlocationcode_CodeArea.south_latitude) / height
        delta_west = (centroid_openlocationcode_CodeArea.west_longitude - southwest_openlocationcode_CodeArea.west_longitude) / width

        # Construct and return the UBID code.
        Kernel.sprintf(FORMAT_STRING_, centroid_openlocationcode, delta_north, delta_east, delta_south, delta_west)
      end

      # Returns the UBID code for the given UBID code area.
      #
      # @param code_area [PNNL::BuildingId::CodeArea]
      # @return [String] The UBID code.
      # @raise [ArgumentError] if the OLC for the centroid of the building footprint cannot be encoded (e.g., invalid code length)
      def self.encode_code_area(code_area)
        raise ArgumentError.new('Invalid PNNL::BuildingId::CodeArea') if code_area.nil?

        # Delegate.
        encode(code_area.south_latitude, code_area.west_longitude, code_area.north_latitude, code_area.east_longitude, code_area.centroid_code_area.latitude_center, code_area.centroid_code_area.longitude_center, codeLength: code_area.centroid_code_length)
      end

      # Is the given UBID code valid?
      #
      # @param code [String] the UBID code
      # @return [Boolean] `true` if the UBID code is valid. Otherwise, `false`.
      def self.valid?(code)
        # Undefined UBID codes are invalid.
        return false if code.nil?

        # Attempt to match the regular expression.
        if !(md = RE_PATTERN_.match(code)).nil?
          open_location_code.valid?(md[RE_GROUP_OPENLOCATIONCODE_])
        else
          # UBID codes that fail to match the regular expression are invalid.
          false
        end
      end

      private

      # Singleton instance of OLC.
      #
      # @return [PlusCodes::OpenLocationCode]
      def self.open_location_code
        @@open_location_code ||= PlusCodes::OpenLocationCode.new
      end
    end
  end
end
