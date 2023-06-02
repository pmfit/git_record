require 'yaml'
require "git_record/github_api/configuration"

module GitRecord
  class Configuration
    attr_accessor :github
    attr_accessor :commit

    def initialize(github: {}, commit: {})
      self.github = GithubApi::Configuration.new(yaml_config[:github].merge(github))
      self.commit = {
        create: "git_record: created file",
        update: "git_record: updated file",
        destroy: "git_record: destroyed file",
        batch: "git_record: batch update"
      }.merge(yaml_config[:commit].merge(commit))
    end

    def yaml_config
      YAML.load(
        ERB.new(
          File.read(Rails.root.join("config", "git.yml"))
        ).result
      ).deep_symbolize_keys
    end
  end
end