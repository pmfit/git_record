module GitRecord
  class CommitTemplate
    def initialize(template, variables)
      @template = template

      variables.each do |key, value|
        singleton_class.send(:define_method, key) { value }
      end 
    end

    def render
      ERB.new(@template).result(get_binding)
    end

    protected

    def get_binding
      binding
    end
  end
end