require 'yaml'
require "git_record/github_api/configuration"

module GitRecord
  class Configuration
    attr_accessor :github
    attr_accessor :commit
    attr_accessor :markdown

    def initialize(**overrides)
      self.github = load_config_value(:github, overrides)
      self.commit = load_config_value(:commit, overrides)
      self.markdown = load_config_value(:markdown, overrides)
    end

    def load_config_value(key, overrides = {})
      default = default_config[key] || {}
      yaml = yaml_config[key] || {}
      override = overrides[key] || {}

      OpenStruct.new(
        default
          .merge(yaml)
          .merge(override)
      )
    end

    def yaml_config
      YAML.load(
        ERB.new(
          File.read(Rails.root.join("config", "git.yml"))
        ).result
      ).deep_symbolize_keys
    end

    def default_config
      {
        commit: {
          create: "git_record: created file",
          update: "git_record: updated file",
          destroy: "git_record: destroyed file",
          batch: "git_record: batch update"
        },
        markdown: {
          converter: Kramdown::Converter::Html
        }
      }
    end
  end
end