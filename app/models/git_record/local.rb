# frozen_string_literal: true
module GitRecord
  class Local < Base
    def self.all
      pages
        .lazy
        .map do |file_path|
        content = File.read(file_path)
        parsed = FrontMatterParser::Parser.new(:md).call(content)
        relative_path = file_path.gsub("#{content_directory}/", '')
        slug = relative_path
               .gsub(".html#{File.extname(file_path)}", '')
               .gsub(File.extname(file_path), '')
               .gsub(%r{/index$}, '')
               .gsub(%r{^/}, '')
        view = relative_path
               .gsub(Rails.root.join('app/views').to_s, '')
               .gsub(".html#{File.extname(file_path)}", '')
               .gsub(File.extname(file_path), '')

        new(
          file_path: relative_path,
          slug:,
          view:,
          front_matter: JSON.parse(parsed.front_matter.to_json, object_class: OpenStruct),
          raw: parsed.content
        )
      end
  end

    def self.find(slug)
      document = all.find { |document| potential_files(slug).include?(document.slug) }

      raise ActiveRecord::RecordNotFound, "#{slug} document not found" if document.blank?

      document
    end

    def self.where(**args)
      all.filter do |document|
        keys = args.keys

        matches = keys.filter do |key|
          document_value = if key == :slug
                             document.slug
                           else
                             document.front_matter[key]
                           end
          args_value = args[key]

          if args_value.methods.include?(:call)
            args_value.call(document_value)
          else
            args_value == document_value
          end
        end

        matches.length == keys.length
      end
    end

    protected

    def self.pages
      Dir.glob(pages_glob)
    end

    def self.pages_glob
      content_directory.join('**/*.{erb,md,html.erb,html.md}')
    end

    def self.content_directory
      Rails.root.join('app', 'views', view_key).freeze
    end

    def self.view_key
      model_name.collection
    end
  end
end
