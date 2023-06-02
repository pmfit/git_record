require 'rails_helper'

RSpec.describe GitRecord::MarkdownParser do
  describe '#to_html' do
    before do
      class Converter < Kramdown::Converter::Html
        def convert_header(el, indent)    
          level = el.options[:level]
    
          format_as_block_html("h#{level}", {}, inner(el, indent), indent)
        end
      end
    end
    
    it 'returns a valid HTML string' do
      expect(described_class.to_html('# Hello world')).to eq("<h1 id=\"hello-world\">Hello world</h1>\n")
    end

    it 'returns a custom HTML string when a converter is configured' do
      allow(GitRecord).to receive(:configuration).and_return(OpenStruct.new(
        markdown: OpenStruct.new(
          converter: Converter
        )
      ))

      expect(described_class.to_html('# Hello world')).to eq("<h1>Hello world</h1>\n")
    end
  end
end