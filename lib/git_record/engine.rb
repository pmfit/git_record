module GitRecord
  class Engine < ::Rails::Engine
    isolate_namespace GitRecord

    config.autoload_paths << File.expand_path('./erb_template_handler.rb', __dir__)
    config.autoload_paths << File.expand_path('./markdown_template_handler', __dir__)
    config.autoload_paths += Dir[File.expand_path('./api/**', __dir__)]
    config.autoload_paths += Dir[File.expand_path('../app/**', __dir__)]

    initializer 'git_record.load' do
      ActiveSupport.on_load :action_view do
        ActionView::Template.register_template_handler(
          'html.erb',
          GitRecord::ErbTemplateHandler
        )

        ActionView::Template.register_template_handler(
          'html.md',
          GitRecord::MarkdownTemplateHandler
        )
      end
    end
  end
end
