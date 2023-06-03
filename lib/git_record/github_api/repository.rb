require_relative './base'
require_relative './branch'
require_relative './client'
require_relative './contents'
require_relative './reference'
require_relative './tree'

module GitRecord
  module GithubApi
    class Repository < Base
      VISIBILITY = {
        public: 'public',
        private: 'hidden'
      }

      attribute :id, :string
      attribute :name, :string
      attribute :full_name, :string
      attribute :description, :string
      attribute :url, :string

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

      def update(**attributes)
        payload = self.class.client.patch("/repos/#{full_name}", attributes.to_json)
      end

      def destroy
        payload = self.class.client.delete("/repos/#{full_name}")
      end

      def contents(path, branch: nil)
        Contents.find(path, full_name, ref: branch)
      end

      def branch(branch)
        Branch.find(branch, full_name)
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