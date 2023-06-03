require "base64"
require 'git_record/commit_template'

require_relative './base'
require_relative './client'
require_relative './contents'

module GitRecord
  module GithubApi
    class Commit < Base
      attribute :sha, :string
      attribute :message, :string
      attribute :author, :hash
      attribute :commiter, :hash
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

        payload[:repo_full_name] = repo_full_name

        self.new(**payload)
      end

      def self.create(message, tree_sha, repo_full_name, parents: nil, committer: nil, author: nil, signature: nil)
        body = {
          message:,
          tree: tree_sha
        }
        body[:parents] = parents if parents.present?
        body[:committer] = commiter if committer.present?
        body[:author] = author if author.present?
        body[:signature] = signature if signature.present?

        payload = self.client.post("/repos/#{repo_full_name}/git/commits", body.to_json)

        self.new(**payload)
      end

      def tree
        Tree.find(self._payload["tree"]["sha"], repo_full_name)
      end
    end
  end
end