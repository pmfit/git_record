require 'kramdown'
require 'htmlentities'

module GitRecord
  class MarkdownParser
    def self.to_html(markdown)
      document = Kramdown::Document.new(markdown, syntax_highlighter: 'rouge')
      compiled_html = MarkdownConverter.convert(document.root, document.options).first
      safe_html = HTMLEntities.new.decode(compiled_html).gsub(/“/, '"')
                              .gsub('‘', "'")
                              .gsub('’', "'")
                              .html_safe
    end
  end

  class MarkdownConverter < Kramdown::Converter::Html
    def convert_header(el, indent)
      super

      level = el.options[:level]
      classes = ['max-w-prose w-full']
      case level
      when 1
        classes.push('mt-6')
      when 2
        classes.push('mt-4')
      when 3
        classes.push('mt-2')
      end

      format_as_block_html("h#{level}", generate_attrs(el, classes), inner(el, indent), indent)
    end

    def convert_p(el, indent)
      super

      classes = ['max-w-prose w-full']

      if el.options[:transparent]
        inner(el, indent)
      elsif el.children.size == 1 && el.children.first.type == :img &&
            el.children.first.options[:ial]&.[](:refs)&.include?('standalone')
        convert_standalone_image(el, indent)
      else
        format_as_block_html('p', generate_attrs(el, classes), inner(el, indent), indent)
      end
    end

    def convert_ul(el, indent)
      state = super

      classes = ['flex flex-col gap-2']

      return unless state.present?

      format_as_indented_block_html(el.type, generate_attrs(el, classes), inner(el, indent), indent)
    end

    def convert_img(el, _indent)
      super

      classes = ['mx-auto']

      el.attr['src'] = if el.attr['src'].starts_with?('%=')
                        el.attr['src'].gsub(/%=/, '<%=').gsub(/%$/, '%>')
                      else
                        el.attr['src']
                      end

      format_as_span_html('img', generate_attrs(el, classes), nil)
    end

    def convert_codeblock(el, indent)
      el.attr["class"] = "" if el.attr["class"].blank?
      el.attr["class"] += " w-full p-4 rounded-md bg-slate-900 [&_pre.highlight]:bg-slate-900 [&_code]:text-slate-50"

      super(el, indent)
    end

    def convert_codespan(el, _indent)
      el.attr["class"] = "" if el.attr["class"].blank?
      el.attr["class"] += " px-2 py-1 rounded-md bg-slate-900 text-slate-50"

      super(el, _indent)
    end

    def convert_details(el, indent)
      classes = []

      format_as_indented_block_html(el.type, generate_attrs(el, classes), inner(el, indent), indent)
    end

    def convert_summary(el, indent)
      classes = []

      format_as_span_html(el.type, generate_attrs(el, classes), inner(el, indent))
    end

    def footnote_content
      ol = Kramdown::Element.new(:ol, nil, 'class' => 'list-none')

      ol.attr['start'] = @footnote_start if @footnote_start != 1

      i = 0
      backlink_text = escape_html(@options[:footnote_backlink], :text)

      while i < @footnotes.length
        name, data, _, repeat = *@footnotes[i]
        li = Kramdown::Element.new(:li, nil, 'id' => "fn:#{name}", 'role' => 'doc-endnote')
        details = Kramdown::Element.new(:details, nil)
        summary = Kramdown::Element.new(:summary, nil)

        summary.children = [Kramdown::Element.new(:raw, "Footnote #{i + 1}")]
        details.children = [
          summary,
          *Marshal.load(Marshal.dump(data.children))
        ]

        para = nil
        if details.children.last.type == :p || @options[:footnote_backlink_inline]
          parent = details
          while !parent.children.empty? && !%i[p header].include?(parent.children.last.type)
            parent = parent.children.last
          end
          para = parent.children.last
          insert_space = true
        end

        unless para
          details.children << (para = Kramdown::Element.new(:p))
          insert_space = false
        end

        unless @options[:footnote_backlink].empty?
          nbsp = entity_to_str(ENTITY_NBSP)
          value = format(FOOTNOTE_BACKLINK_FMT, (insert_space ? nbsp : ''), name, backlink_text)
          para.children << Kramdown::Element.new(:raw, value)
          (1..repeat).each do |index|
            value = format(FOOTNOTE_BACKLINK_FMT, nbsp, "#{name}:#{index}",
                          "#{backlink_text}<sup>#{index + 1}</sup>")
            para.children << Kramdown::Element.new(:raw, value)
          end
        end

        li.children = [details]
        ol.children << Kramdown::Element.new(:raw, convert(li, 4))
        i += 1
      end
      if ol.children.empty?
        ''
      else
        format_as_indented_block_html('div',
                                      {
                                        class: 'footnotes w-full p-4 mt-8 rounded-md border border-slate-50',
                                        role: 'doc-endnotes'
                                      },
                                      convert(ol, 2), 0)
      end
    end

    private

    def generate_attrs(el, classes = [])
      { **el.attr, class: [el.attr[:class] || '', *classes].join(' ') }
    end
  end
end