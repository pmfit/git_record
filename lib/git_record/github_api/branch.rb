require_relative './reference'

module GitRecord
  module GithubApi
    class Branch < Reference
      def self.find(name, repo_full_name)        
        payload = self.client.get("/repos/#{repo_full_name}/git/ref/heads/#{name}")

        payload[:repo_full_name] = repo_full_name

        self.new(**payload)
      end

      def self.create(name, sha, repo_full_name)
        body = {
          ref: "refs/heads/#{name}",
          sha:
        }
        payload = self.client.post("/repos/#{repo_full_name}/git/refs", body.to_json)

        self.new(**payload)
      end
    end
  end
end