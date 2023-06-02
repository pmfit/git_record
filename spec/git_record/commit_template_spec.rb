require 'rails_helper'

RSpec.describe GitRecord::CommitTemplate do
  describe '#render' do
    it 'renders a basic string' do
      template = described_class.new("hello world", {})

      expect(template.render).to eq("hello world")
    end

    it 'renders a string with variables' do
      template = described_class.new("variable: <%= variable %>", { variable: "foobar" })

      expect(template.render).to eq("variable: foobar")
    end
  end
end