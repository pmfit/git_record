# frozen_string_literal: true
module GitRecord
  class Github < Base
    define_model_callbacks :create, :update, :destroy, :initialize

    def initialize(attributes = {})
      super(attributes)

      run_callbacks :initialize do
        raise ActiveRecord::RecordInvalid, errors unless valid?

        attribute_names.each do |name|
          next if [:file_path, :slug, :view, :front_matter, :raw].include? name.to_sym

          self.send("#{name}=", front_matter[name])
        end
      end
    end

    def save
      file = to_file

      file.update(raw)
    end

    def self.create(attributes = {})

    end

    def self.all
      results = GitRecord::GithubApi::Contents.find("/", repo)
      files = results.filter { |result| result.is_a? GitRecord::GithubApi::File }

      files.lazy.map do |file|
        slug = file.path
          .gsub(".html#{File.extname(file.path)}", '')
          .gsub(File.extname(file.path), '')
          .gsub(%r{/index$}, '')
          .gsub(%r{^/}, '')

        self.new(
          file_path: file.path,
          slug:,
          view: nil
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

    def self.repo
      GitRecord.configuration.github.repo
    end
  end
end
