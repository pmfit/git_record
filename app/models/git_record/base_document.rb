# frozen_string_literal: true
require "git_record/markdown_parser"

module GitRecord
  class BaseDocument
    include ActiveModel::Model
    include ActiveModel::Attributes

    define_model_callbacks :update, :destroy, :initialize

    attribute :path, :string
    attribute :slug, :string
    attribute :content, :string
    attribute :front_matter, default: {}
    attribute :raw_body, :string

    after_initialize :get_file

    def initialize(**attributes)
      super

      run_callbacks :initialize do
        raise StandardError, errors unless valid?

        attribute_names.each do |name|
          next if [:path, :slug, :content, :view, :front_matter, :raw_body].include? name.to_sym

          self.send("#{name}=", front_matter[name])
        end
      end
    end

    attribute_names.each do |name|
      self.define_method("find_by_#{name}") do |value|
        pages = self.all
        document = all.find { |document| document.send(name) === value }

        raise ActiveRecord::RecordNotFound, "#document not found for #{name}: #{value}" if document.blank?

        document
      end
    end

    # YER A WIZARD, HARRY
    def body
      lookup_context = ActionView::LookupContext.new([])
      view = ActionView::Base.with_empty_template_cache.new(lookup_context, {}, nil)

      if path.ends_with?(*lookup_context.handlers.map(&:to_s))
        ext = File.extname(path).gsub(/^./, '')
        template = ActionView::Template.new(content, path, ActionView::Template.handler_for_extension(ext.to_sym), locals: [])
        
        view.render template: template
      else
        raw_body
      end
    end

    def self.potential_files(slug)
      [slug, "#{slug}.html.erb", "#{slug}.md", "#{slug}.html.md", "#{slug}/index.html.erb", "#{slug}/index.md",
       "#{slug}/index.html.md"]
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

    def valid_menus?
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

    protected

    def self.provider
      :github
    end
  end
end
