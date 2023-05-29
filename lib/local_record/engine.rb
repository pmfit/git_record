module LocalRecord
  class Engine < ::Rails::Engine
    isolate_namespace LocalRecord

    config.autoload_paths << File.expand_path('./erb_template_handler.rb', __dir__)
    config.autoload_paths << File.expand_path('./markdown_template_handler', __dir__)
    config.autoload_paths += Dir[File.expand_path('../app/**', __dir__)]

    initializer 'local_record.load' do
      ActiveSupport.on_load :action_view do
        ActionView::Template.register_template_handler(
          'html.erb',
          LocalRecord::ErbTemplateHandler
        )

        ActionView::Template.register_template_handler(
          'html.md',
          LocalRecord::MarkdownTemplateHandler
        )
      end
    end
  end
end
