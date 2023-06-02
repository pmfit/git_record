require "base64"
require 'git_record/commit_template'

require_relative './base'
require_relative './client'
require_relative './contents'

module GitRecord
  module GithubApi
    class Commit < Base
      attribute :message, :string
      attribute :author, :hash
      attribute :commiter, :hash
      attribute :tree, :hash
      attribute :parent, :hash
      attribute :verification, :hash

      attribute :repo_full_name, :string
      attribute :_payload, :hash

      def initialize(**payload)
        attributes = payload.reject{ |k,v| !Commit.attribute_names.include?(k.to_s) }

        super(attributes)

        self._payload = payload
      end

      def self.find(sha, repo_full_name)        
        payload = self.client.get("/repos/#{repo_full_name}/git/commits/#{sha}")

        self.new(**payload)
      end

      def tree
        Tree.find(self.tree.sha)
      end
    end
  end
end