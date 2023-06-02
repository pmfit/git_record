require_relative './base'
require_relative './client'
require_relative './contents'
require_relative './reference'

module GitRecord
  module GithubApi
    class Repository < Base
      attribute :id, :string
      attribute :name, :string
      attribute :full_name, :string
      attribute :description, :string
      attribute :_payload, :hash, default: {}

      validates_presence_of :id
      validates_presence_of :name
      validates_presence_of :full_name

      def initialize(**payload)
        attributes = payload.reject{ |k,v| !Repository.attribute_names.include?(k.to_s) }

        super(attributes)

        self._payload = payload
      end

      def self.find(full_name)        
        payload = self.client.get("/repos/#{full_name}")

        new(**payload.parsed_response)
      end

      def contents(path, branch: nil)
        Contents.find(path, full_name, ref: branch)
      end

      def branch(branch)
        Reference.find("heads/#{branch}", full_name)
      end

      def commit(sha)
        Commit.find(sha, full_name)
      end

      def blob(sha)
        Blob.find(sha, full_name)
      end

      def tag(sha)
        Tag.find(sha, full_name)
      end

      def tree(sha)
        Tree.find(sha, full_name)
      end
    end
  end
end