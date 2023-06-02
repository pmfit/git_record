require "git_record/version"
require "git_record/engine"
require "git_record/configuration"
require "git_record/markdown_parser"
require "git_record/erb_template_handler"
require "git_record/markdown_template_handler"
require "git_record/active_model"
require "git_record/commit_template"
require "git_record/github_api/repository"

module GitRecord
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
