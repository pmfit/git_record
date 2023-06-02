require 'rails_helper'

RSpec.describe GitRecord do
  describe 'VERSION' do
    it 'is defined' do
      expect(GitRecord::VERSION).to be_present
    end
  end

  describe '#configuration' do
    it 'responds with a valid configuration object' do
      expect(GitRecord.configuration).to be_a(GitRecord::Configuration)
    end

    it 'responds with pmfit/git_record from config/git.yml' do
      expect(GitRecord.configuration.github.repo).to eq("pmfit/git_record")
    end

    it 'responds with test from .env' do
      expect(GitRecord.configuration.github.access_token).to eq("test")
    end

    it 'responds with custom value from configurator' do
      GitRecord.configure do |config|
        config.github.access_token = "abc123"
      end

      expect(GitRecord.configuration.github.access_token).to eq("abc123")
    end
  end
end