require 'httpparty'

module GitRecord
  module GithubApi
    class RestClient
      include HTTParty

      base_uri 'https://api.github.com'

      def initialize(options)
        @options = options.to_h
      end

      def get(url, headers: {})
        response = self.class.get(url, headers: allowed_headers(headers))

        handle_response(response)
      end

      def post(url, body, headers: {})
        response = self.class.post(url, body: body, headers: allowed_headers(headers))

        handle_response(response)
      end

      def put(url, body, headers: {})
        response = self.class.put(url, body: body, headers: allowed_headers(headers))

        handle_response(response)
      end

      def patch(url, body, headers: {})
        response = self.class.patch(url, body: body, headers: allowed_headers(headers))

        handle_response(response)
      end

      def delete(url, headers: {})
        response = self.class.delete(url, headers: allowed_headers(headers))

        handle_response(response)
      end

      protected

      def allowed_headers(headers)
        headers.merge({
          "Content-Type": "application/json",
          "Accept": "application/vnd.github+json",
          "Authorization": "Bearer #{@options[:access_token]}",
          "X-GitHub-Api-Version": @options[:github_version]
        })
      end

      private

      def handle_response(response)
        unless response.success?
          raise StandardError, response["message"]
        end

        response
      end
    end
  end
end