require 'digest'

require_relative './base'
require_relative './client'
require_relative './contents'

module GitRecord
  module GithubApi
    EMPTY_TREE_SHA = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'

    class Tree < Base
      attribute :sha, :string

      attribute :repo_full_name, :string
      attribute :_payload, :hash

      def initialize(**payload)
        attributes = payload.reject{ |k,v| !Tree.attribute_names.include?(k.to_s) }

        super(attributes)

        self._payload = payload
      end

      def self.find(sha, repo_full_name, recursive: false)
        url = URI("/repos/#{repo_full_name}/git/trees/#{sha}")        
        url.query[:recursive] = true if recursive

        payload = self.client.get(url.path)
        payload[:repo_full_name] = repo_full_name

        self.new(**payload)
      end

      def self.create(tree, repo_full_name, base_tree: nil)
        body = {
          tree:
        }
        body[:base_tree] = base_tree if base_tree.present?

        payload = self.client.post("/repos/#{repo_full_name}/git/trees", body.to_json)

        self.new(**payload)
      end

      def contents
        @tree
      end

      def contents=(tree)
        @tree = tree
      end

      def add_file(path, content)
        @tree ||= []
        @tree.push({
          path:,
          content:,
          mode: '100644',
          type: 'blob'
        })
      end

      def add_executable(path, content)
        @tree ||= []
        @tree.push({
          path:,
          content:,
          mode: '100755',
          type: 'blob'
        })
      end

      def add_directory
        @tree ||= []
        @tree.push({
          path:,
          content:,
          mode: '040000',
          type: 'tree'
        })
      end

      def dup
        if @tree.present?
          self.class.create(@tree, repo_full_name, base_tree: sha)
        else
          raise StandardError, 'Please construct a new tree'
        end
      end
    end
  end
end