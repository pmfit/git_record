require 'httpparty'

module GitRecord
  module GithubApi
    class Base
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::Serialization

      def initialize(attrs)
        super(attrs)
      end

      protected

      def self.client
        RestClient.new(GitRecord.configuration.github)
      end
    end
  end
end