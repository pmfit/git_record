# frozen_string_literal: true
require 'front_matter_parser'

module GitRecord
  class Github < BaseDocument
    define_model_callbacks :create, :update, :destroy, :initialize

    def initialize(attributes = {})
      @file = attributes.delete(:file)

      super(**attributes)
    end

    def self.all
      results = GitRecord::GithubApi::Contents.find("/", repo_full_name)
      files = results.filter { |result| result.is_a?(GithubApi::File) }

      files.lazy.map(&:file_to_record)
    end

    def self.find(path)
      file = GitRecord::GithubApi::File.find(path, repo_full_name)

      file_to_record(file)
    end

    def self.find_by(**attributes)
      file = all.find do |result|
        return false unless result.is_a?(GithubApi::File)

        attributes.each do |key, value|
          return false unless result.send(key).include? value
        end
      end

      file_to_record(file) if file.present?
    end

    def self.where(**attributes)
      files = all.filter do |result|
        return false unless result.is_a?(GithubApi::File)

        attributes.each do |key, value|
          return false unless result.send(key).include? value
        end

        true
      end

      files.map(&:file_to_record) if files.present?
    end

    def self.create(path, content: nil, **attributes)
      contents = ""

      unless attributes.blank?
        contents += "#{attributes.stringify_keys.to_yaml}"
        contents += "---\n"
      end

      if content.present?
        contents += "#{content}\n"
      end

      GithubApi::File.create(path, repo_full_name, contents)

      return true
    rescue
      return false
    end

    def create!(**attrs)
      raise StandardError, 'Failed to create' unless create(**attrs)
    end

    def update(content: nil, **attributes)
      contents = ""

      unless attributes.blank?
        contents += "#{attributes.merge(front_matter.to_h).stringify_keys.to_yaml}"
        contents += "---\n"
      else
        contents += "#{front_matter.stringify_keys.to_yaml}"
        contents += "---\n"
      end

      if content.present?
        contents += "#{content}\n"
      else
        contents += "#{raw}\n"
      end

      @file.update(contents)
    end

    def update!(**attrs)
      raise StandardError, 'Failed to update' unless update(**attrs)
    end

    protected

    def self.file_to_record(file)
      file_type = File.extname(file.path).gsub(/^./, '')
      slug = file.path
        .gsub(".html#{File.extname(file.path)}", '')
        .gsub(File.extname(file.path), '')
        .gsub(%r{/index$}, '')
        .gsub(%r{^/}, '')
      parsed = FrontMatterParser::Parser.new(file_type.to_sym).call(file.decoded_content) if file.decoded_content.present?
      
      self.new(
        path: file.path,
        slug:,
        content: file.decoded_content,
        front_matter: parsed.front_matter,
        raw_body: parsed.content,
        file: file
      )
    end

    def self.repo_full_name
      GitRecord.configuration.github.repo
    end
  end
end
