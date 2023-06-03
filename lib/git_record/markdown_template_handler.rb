# frozen_string_literal: true
require 'front_matter_parser'

module GitRecord
  class MarkdownTemplateHandler
    def self.erb
      @erb ||= ActionView::Template.registered_template_handler(:erb)
    end

    def self.call(template, source)
      parsed_source = FrontMatterParser::Parser.new(:md).call(source)
      safe_html = MarkdownParser.to_html(parsed_source.content)
      erb_template = ActionView::Template.new(safe_html, 'virtual.erb', ActionView::Template.handler_for_extension(:erb), locals: OpenStruct.new(parsed_source.front_matter))

      erb.call(erb_template, safe_html)
    end
  end
end
