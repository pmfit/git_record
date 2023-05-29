# frozen_string_literal: true
require 'front_matter_parser'
require "local_record/markdown_parser"

module LocalRecord
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :file_path, :string
    attribute :slug, :string
    attribute :view, :string
    attribute :front_matter, default: {}
    attribute :raw, :string

    validate :valid_menus
    def initialize(attributes = {})
      super

      raise ActiveRecord::RecordInvalid, errors unless valid?

      attribute_names.each do |name|
        next if [:file_path, :slug, :view, :front_matter, :raw].include? name.to_sym

        self.send("#{name}=", front_matter[name])
      end
    end

    def body
      LocalRecord::MarkdownParser.to_html(raw) if file_path.ends_with?('.md')
    end

    def self.all
      pages
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

    def self.potential_files(slug)
      [slug, "#{slug}.html.erb", "#{slug}.md", "#{slug}.html.md", "#{slug}/index.html.erb", "#{slug}/index.md",
       "#{slug}/index.html.md"]
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

    def menu(id)
      return if id.blank?

      front_matter.menus.find do |menu|
        menu.id.to_sym == id.to_sym
      end
    end

    def menus
      return nil unless front_matter.menus.present?

      documents = self.class.all

      # recurse menus and construct an object with each menu id
      # where the value is a multi-dimensional array representing the tree
      menus = front_matter.menus.each_with_object({}) do |menu, menus|
        next if menu.id.blank?

        menu_documents = documents.filter do |document|
          next if document.front_matter.menus.blank?

          document.front_matter.menus.find { |m| m.id == menu.id }.present?
        end

        menus[menu.id] = menu_documents

        menus
      end

      menus.each_key do |key|
        menus[key].sort! do |a, b|
          a_order = a.front_matter.menus.find { |menu| menu.id == key }&.order |= 0
          b_order = b.front_matter.menus.find { |menu| menu.id == key }&.order |= 0

          b_order.to_i <=> a_order.to_i
        end

        menus[key] = menus[key].reverse
      end

      OpenStruct.new(menus)
    end

    def valid_menus
      return false if front_matter.menus.blank?
      return false unless front_matter.menus.is_a? Array

      invalid = front_matter.menus.find do |menu|
        menu.id.blank?
      end

      invalid.present?
    end

    def to_param
      slug
    end
  end
end
