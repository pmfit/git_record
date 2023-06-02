require 'uri'

require_relative './base'
require_relative './client'
require_relative './file'
require_relative './directory'

module GitRecord
  module GithubApi
    class Contents < Base
      def self.find(path, repo_full_name, ref: nil)
        uri = URI("/repos/#{repo_full_name}/contents/#{path.gsub(/^\//, "")}")
        uri.query = "ref=#{ref}" if ref.present?
        url = uri.to_s

        response = self.client.get(url)
        payloads = response.parsed_response.is_a?(Array) ? response.parsed_response : [response.parsed_response]


        entities = payloads.map do |payload|
          case payload["type"]
          when "dir"
            payload[:repo_full_name] = repo_full_name

            Directory.new(**payload)
          when "file"
            payload[:repo_full_name] = repo_full_name

            File.new(**payload)
          else
            Rails.logger.error("Unknown contents: #{payload["type"]}")

            nil
          end
        end

        entities.filter do |entity|
          entity.present?
        end
      end
    end
  end
end