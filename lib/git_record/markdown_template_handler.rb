# frozen_string_literal: true
require 'front_matter_parser'

module GitRecord
  class MarkdownTemplateHandler
    def self.erb
      @erb ||= ActionView::Template.registered_template_handler(:erb)
    end

    def self.call(template, source)
      parsed_source = FrontMatterParser::Parser.new(:md).call(source)
      interpolated_template = ActionView::Template.new(parsed_source.content, template.identifier, template.handler,
                                                       locals: OpenStruct.new(parsed_source.front_matter))
      safe_html = MarkdownParser.to_html(parsed_source.content)

      erb.call(interpolated_template, safe_html)
    end
  end
end
