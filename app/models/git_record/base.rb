# frozen_string_literal: true
require 'front_matter_parser'

module GitRecord
  class Base < BaseDocument
    attribute :view, :string

    define_model_callbacks :initialize

    validate :valid_menus?

    def initialize(attributes = {})
      super(**attributes)

      run_callbacks :initialize do
        raise StandardError, errors unless valid?

        attribute_names.each do |name|
          next if [:path, :slug, :view, :front_matter, :raw].include? name.to_sym

          self.send("#{name}=", front_matter[name])
        end
      end
    end

    def self.all
      pages
        .map do |path|
          file = File.new(path, 'r')
        
          file_to_record(file)
      end
  end

    def self.find(slug)
      document = all.find { |document| potential_files(slug).include?(document.slug) }

      raise StandardError, "#{slug} document not found" if document.blank?

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

    def self.file_to_record(file)
      content = file.read
      parsed = FrontMatterParser::Parser.new(:md).call(content)
      relative_path = file.path.gsub("#{content_directory}/", '')
      slug = relative_path
             .gsub(".html#{File.extname(file.path)}", '')
             .gsub(File.extname(file.path), '')
             .gsub(%r{/index$}, '')
             .gsub(%r{^/}, '')
      view = relative_path
             .gsub(Rails.root.join('app/views').to_s, '')
             .gsub(".html#{File.extname(file.path)}", '')
             .gsub(File.extname(file.path), '')

      self.new(
        path: file.path,
        slug:,
        view:,
        front_matter: parsed.front_matter,
        raw_body: parsed.content
      )
    end

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
