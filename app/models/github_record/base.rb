# frozen_string_literal: true
require 'front_matter_parser'

module GithubRecord
  class Base < BaseDocument
    define_model_callbacks :create, :update, :destroy, :initialize

    def initialize(attributes = {})
      @file = attributes.delete(:file)

      super(**attributes)
    end

    def self.all(branch: nil)
      query(branch:).eager
    end

    def self.find(path, branch: nil)
      file = GitRecord::GithubApi::File.find(path, repo_full_name, branch: branch)

      file_to_record(file)
    end

    def self.find_by(branch: nil, **attributes)
      where(**attributes).first
    end

    def self.where(branch: nil, **attributes)
      query(branch:).filter do |document|
        keys = attributes.keys

        matches = keys.filter do |key|
          document_value = if key == :slug
                             document.slug
                           else
                             document.send(key)
                           end
          attribute = attributes[key]

          if attribute.methods.include?(:call)
            attribute.call(document_value)
          else
            attribute == document_value
          end
        end

        matches.length == keys.length
      end
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

      GitRecord::GithubApi::File.create(path, repo_full_name, contents)

      true
    rescue StandardError => e
      errors.add(:base, e.message)

      false
    end

    def create!(**attrs)
      raise StandardError, errors(:base) || 'Failed to create' unless create(**attrs)
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

      true
    rescue StandardError => e
      errors.add(:base, e.message)

      false
    end

    def update!(**attrs)
      raise StandardError, errors(:base) || 'Failed to update' unless update(**attrs)
    end

    protected

    def self.query(branch: nil)
      repo = GitRecord::GithubApi::Repository.find(repo_full_name)
      tree = repo.branch(branch || repo.default_branch).tree(recursive: true)
      files = tree.contents
        .lazy
        .filter { |content| content["type"] == "blob" }
        .map { |content| GitRecord::GithubApi::File.find(content["path"], repo_full_name) }

      files.map { |file| file_to_record(file) }
    end

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
