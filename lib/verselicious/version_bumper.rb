# frozen_string_literal: true

module Verselicious
  class VersionBumper
    VALID_BUMP_TYPES = %w[major minor patch].freeze

    def initialize(current_version)
      @major, @minor, @patch = parse(current_version)
    end

    def bump(type)
      validate_bump_type(type)

      case type
      when 'major' then "#{@major + 1}.0.0"
      when 'minor' then "#{@major}.#{@minor + 1}.0"
      when 'patch' then "#{@major}.#{@minor}.#{@patch + 1}"
      end
    end

    private

    def parse(version)
      parts = version.split('.')
      raise ArgumentError, "Invalid version format: #{version}" unless parts.length == 3

      parts.map do |part|
        Integer(part)
      rescue ArgumentError
        raise ArgumentError, "Invalid version component: #{part}"
      end
    end

    def validate_bump_type(type)
      return if VALID_BUMP_TYPES.include?(type)

      raise ArgumentError, "Invalid bump type: #{type}. Must be one of: #{VALID_BUMP_TYPES.join(', ')}"
    end
  end
end
