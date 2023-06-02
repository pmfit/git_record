require 'httpparty'

module GitRecord
  module GithubApi
    class Configuration
      attr_accessor :api_version
      attr_accessor :repo
      attr_accessor :access_token

      def initialize(config)
        self.api_version = config[:api_version] || "2022-11-28"
        self.repo = config[:repo]
        self.access_token = config[:access_token]
      end

      def to_h
        {
          api_version:,
          repo:,
          access_token:
        }
      end
    end
  end
end