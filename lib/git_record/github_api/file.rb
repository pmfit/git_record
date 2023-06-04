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

        @content = payload["content"]
      end

      def self.create(path, repo_full_name, contents, branch: nil)
        content_base64 = Base64.encode64(contents)

        body = {
          message: GitRecord::CommitTemplate.new(GitRecord.configuration.commit[:create], { path: path }).render,
          content: content_base64.gsub("\n", ''),
        }
        body[:branch] = branch if branch.present?

        url = "/repos/#{repo_full_name}/contents/#{path}"

        payload = self.client.put(url, body.to_json)
        
        new(**payload)
      end

      def self.find(path, repo_full_name, branch: nil)        
        response = Contents.find(path, repo_full_name, ref: branch)

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

        body = {
          message: GitRecord::CommitTemplate.new(GitRecord.configuration.commit[:update], serializable_hash).render,
          content: content_base64.gsub("\n", ''),
          sha: sha
        }
        body[:branch] = branch if branch.present?
      
        payload = self.class.client.put(url, body.to_json)
        
        self.class.new(**payload)
      end

      def content
       return @content if @content.present?

       full_file = self.class.find(path, repo_full_name)

       @content = full_file.content

       @content
      end

      def decoded_content
        return Base64.decode64(content) if content.present?

        ''
      end
    end
  end
end