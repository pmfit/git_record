require 'rails_helper'

RSpec.describe GitRecord::GithubApi::Tree do
  describe '#find' do
    it 'finds a tree by sha' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/trees/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "sha": "abc123" }.to_json
        )

      expect(described_class.find('abc123', "pmfit/git_record")).to be_a(described_class)
      expect(described_class.find('abc123', "pmfit/git_record").sha).to eq("abc123")
    end

    it 'raises an error when the sha is not found' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/trees/abc123")
        .to_return(
          status: 404,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Not found" }.to_json
        )

      expect { described_class.find('abc123', "pmfit/git_record") }.to raise_error(StandardError, 'Not found')
    end

    it 'raises an error when it fails' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/trees/abc123")
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
      stub_request(:post, "https://api.github.com/repos/pmfit/git_record/git/trees")
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

  describe 'tree' do
    pending 'returns the tree for the commit' do
      commit = described_class.new(tree: { "sha": "abc123"})
      
      expect(commit.tree).to be_a(GitRecord::GithubApi::Tree)
    end
  end
end
