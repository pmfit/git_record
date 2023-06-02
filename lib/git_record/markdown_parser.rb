require 'kramdown'
require 'htmlentities'

module GitRecord
  class MarkdownParser
    def self.to_html(markdown)
      converter = GitRecord.configuration.markdown.converter
      document = Kramdown::Document.new(markdown, syntax_highlighter: 'rouge')
      compiled_html = converter.convert(document.root, document.options).first
      safe_html = HTMLEntities.new.decode(compiled_html).gsub(/“/, '"')
                              .gsub('‘', "'")
                              .gsub('’', "'")
                              .html_safe
    end
  end
end