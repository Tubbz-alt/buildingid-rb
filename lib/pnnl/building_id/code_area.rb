# frozen_string_literal: true

module PNNL
  module BuildingId
    # A UBID code area.
    class CodeArea
      attr_reader :centroid_code_area, :centroid_code_length, :north_latitude, :south_latitude, :east_longitude, :west_longitude

      # Default constructor.
      #
      # @param centroid_code_area [PlusCodes::CodeArea]
      # @param centroid_code_length [Integer]
      # @param north_latitude [Float]
      # @param south_latitude [Float]
      # @param east_longitude [Float]
      # @param west_longitude [Float]
      def initialize(centroid_code_area, centroid_code_length, north_latitude, south_latitude, east_longitude, west_longitude)
        @centroid_code_area = centroid_code_area
        @centroid_code_length = centroid_code_length
        @north_latitude = north_latitude
        @south_latitude = south_latitude
        @east_longitude = east_longitude
        @west_longitude = west_longitude
      end

      # Returns a resized version of this UBID code area, where the latitude and
      # longitude of the lower left and upper right corners of the OLC bounding
      # box are moved inwards by dimensions that correspond to half of the height
      # and width of the OLC grid reference cell for the centroid.
      #
      # The purpose of the resizing operation is to ensure that re-encoding a
      # given UBID code area results in the same coordinates.
      #
      # @return [PNNL::BuildingId::CodeArea]
      def resize
        # Calculate the (half-)dimensions of OLC grid reference cell for the
        # centroid.
        half_height = Float(@centroid_code_area.north_latitude - @centroid_code_area.south_latitude) / 2.0
        half_width = Float(@centroid_code_area.east_longitude - @centroid_code_area.west_longitude) / 2.0

        # Construct and return the new UBID code area.
        self.class.new(
          @centroid_code_area,
          @centroid_code_length,
          @north_latitude - half_height,
          @south_latitude + half_height,
          @east_longitude - half_width,
          @west_longitude + half_width
        )
      end
    end
  end
end
