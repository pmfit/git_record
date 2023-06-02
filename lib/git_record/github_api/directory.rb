require "base64"
require 'git_record/commit_template'

require_relative './base'
require_relative './client'
require_relative './contents'

module GitRecord
  module GithubApi
    class Directory < Base      
      attribute :name, :string
      attribute :path, :string
      attribute :sha, :string
      attribute :size, :string

      attribute :repo_full_name, :string
      attribute :_payload, :hash

      def initialize(**payload)
        attributes = payload.reject{ |k,v| !Directory.attribute_names.include?(k.to_s) }

        super(attributes)

        self._payload = payload
      end

      def self.find(path, repo_full_name)        
        response = Contents.find(path, repo_full_name)

        response[:repo_full_name] = repo_full_name

        response.first
      end

      def contents
        Contents.find(path, repo_full_name)
      end
    end
  end
end