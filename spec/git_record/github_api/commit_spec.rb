require 'rails_helper'

RSpec.describe GitRecord::GithubApi::Commit do
  describe '#find' do
    it 'finds a commit by sha' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/commits/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "sha": "abc123" }.to_json
        )

      expect(described_class.find('abc123', "pmfit/git_record")).to be_a(described_class)
      expect(described_class.find('abc123', "pmfit/git_record").sha).to eq("abc123")
    end

    it 'raises an error when the sha is not found' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/commits/abc123")
        .to_return(
          status: 404,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Not found" }.to_json
        )

      expect { described_class.find('abc123', "pmfit/git_record") }.to raise_error(StandardError, 'Not found')
    end

    it 'raises an error when it fails' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/commits/abc123")
        .to_return(
          status: 417,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Something went wrong" }.to_json
        )

      expect { described_class.find("abc123", "pmfit/git_record") }.to raise_error(StandardError, "Something went wrong")
    end
  end

  describe '#create' do
    it 'creates a new commit' do
      stub_request(:post, "https://api.github.com/repos/pmfit/git_record/git/commits")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Hello world", "sha": "abc123" }.to_json
        )
      commit = described_class.create("Hello world", "abc123", "pmfit/git_record")
        
      expect(commit.message).to eq("Hello world")
      expect(commit.sha).to eq("abc123")
    end
  end
end
