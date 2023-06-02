require "base64"
require 'git_record/commit_template'

require_relative './base'
require_relative './client'
require_relative './contents'

module GitRecord
  module GithubApi
    class Commit < Base

      attribute :repo_full_name, :string
      attribute :_payload, :hash

      def initialize(**payload)
        attributes = payload.reject{ |k,v| !Tree.attribute_names.include?(k.to_s) }

        super(attributes)

        self._payload = payload
      end

      def self.find(sha, repo_full_name)        
        payload = self.client.get("/repos/#{repo_full_name}/git/trees/#{sha}")

        payload[:repo_full_name] = repo_full_name

        self.new(**payload)
      end
    end
  end
end