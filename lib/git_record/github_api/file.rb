require "base64"
require 'git_record/commit_template'

require_relative './base'
require_relative './contents'

module GitRecord
  module GithubApi
    class File < Base
      attribute :sha, :string
      attribute :name, :string
      attribute :path, :string
      
      attribute :url, :string
      attribute :repo_full_name, :string
      attribute :_payload, :hash

      validates_presence_of :sha
      validates_presence_of :name
      validates_presence_of :path

      def initialize(**payload)
        attributes = payload.reject{ |k,v| !File.attribute_names.include?(k.to_s) }

        super(attributes)

        self._payload = payload

        @content = payload[:content]
      end

      def self.create(path, repo_full_name, contents, branch: nil)
        content_base64 = Base64.encode64(contents)

        payload = {
          message: GitRecord::CommitTemplate.new(GitRecord.configuration.commit[:create], { path: path }).render,
          content: content_base64.gsub("\n", ''),
        }
        payload[:branch] = branch if branch.present?

        url = "/repos/#{repo_full_name}/contents/#{path}"

        response_payload = self.client.put(url, JSON.generate(payload))
        
        new(**response_payload)
      end

      def self.find(path, repo_full_name)        
        response = Contents.find(path, repo_full_name)

        klass = response.first
        if !klass.is_a? File
          raise StandardError, "#{path} is a #{klass._payload["type"]}"
        end

        if klass.path != path
          raise StandardError, "Something went horribly wrong. #{klass.path} does not match #{path}..."
        end

        klass
      end

      def update(contents, branch: nil)
        content_base64 = Base64.encode64(contents)

        payload = {
          message: GitRecord::CommitTemplate.new(GitRecord.configuration.commit[:create], self.to_h).render,
          content: content_base64.gsub("\n", ''),
          sha: sha
        }
        payload[:branch] = branch if branch.present?
      
        response_payload = self.class.client.put(url, JSON.generate(payload))
        
        self.class.new(**response_payload)
      end

      def content
       return @content if @content.present?

       full_file = self.find(path, repo_full_name)

       @content = full_file.content

       @content
      end

      def raw_content
        return Base64.decode64(content) if content.present?

        ''
      end
    end
  end
end