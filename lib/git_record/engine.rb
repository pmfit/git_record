module GitRecord
  class Engine < ::Rails::Engine
    isolate_namespace GitRecord

    config.autoload_paths += Dir[File.expand_path('./**', __dir__)]
    config.autoload_paths += Dir[File.expand_path('../app/**', __dir__)]

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'git_record.load' do
      ActiveSupport.on_load :action_view do
        ActionView::Template.register_template_handler(
          *['html.erb'],
          GitRecord::ErbTemplateHandler
        )

        ActionView::Template.register_template_handler(
          *[:md, 'html.md'],
          GitRecord::MarkdownTemplateHandler
        )
      end
    end
  end
end
