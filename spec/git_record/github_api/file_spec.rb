require 'rails_helper'

RSpec.describe GitRecord::GithubApi::File do
  it 'validates the presence of an sha' do
    repo = described_class.new(name: 'abc123', path: 'abc123')

    expect(repo.valid?).to be(false)
    expect(repo.errors.full_messages).to eq(["Sha can't be blank"])
  end

  it 'validates the presence of an name' do
    repo = described_class.new(sha: 'abc123', path: 'abc123')

    expect(repo.valid?).to be(false)
    expect(repo.errors.full_messages).to eq(["Name can't be blank"])
  end

  it 'validates the presence of a path' do
    repo = described_class.new(sha: 'abc123', name: 'abc123')

    expect(repo.valid?).to be(false)
    expect(repo.errors.full_messages).to eq(["Path can't be blank"])
  end

  describe '#find' do
    it 'finds a file in the github repository by file path' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "type": "file", "path": "abc123" }.to_json
        )

      expect(described_class.find('abc123', "pmfit/git_record")).to be_a(described_class)
    end

    it 'raises an error when the path is not found' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 404,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Not found" }.to_json
        )

      expect { described_class.find('abc123', "pmfit/git_record") }.to raise_error(StandardError, 'Not found')
    end

    it 'raises an error when the found path is not a file' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: [{ "type": "dir" }].to_json
        )

      expect { described_class.find('abc123', "pmfit/git_record") }.to raise_error(StandardError, 'abc123 is a dir')
    end

    it 'raises an error when the found file does not match the requested file' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "type": "file", path: "123abc" }.to_json
        )

      expect { described_class.find('abc123', "pmfit/git_record") }.to raise_error(StandardError, 'Something went horribly wrong. 123abc does not match abc123...')
    end

    it 'raises an error when it fails' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 417,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Something went wrong" }.to_json
        )

      expect { described_class.find("abc123", "pmfit/git_record") }.to raise_error(StandardError, "Something went wrong")
    end
  end

  describe '#create' do
    it 'returns a the newly created file' do
      stub_request(:put, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "type": "file" }.to_json
        )

      expect(described_class.create("abc123", "pmfit/git_record", "content")).to be_a(described_class)
    end

    it 'raises an error when it fails' do
      stub_request(:put, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 417,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Something went wrong" }.to_json
        )

      expect { described_class.create("abc123", "pmfit/git_record", "content") }.to raise_error(StandardError, "Something went wrong")
    end
  end

  describe '#update' do
    it 'returns the updated file' do
      file = described_class.new(url: "https://api.github.com/repos/pmfit/git_record/contents/abc123")

      stub_request(:put, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "type": "file", "content": "abc123" }.to_json
        )

      expect(file.update('abc123').content).to eq("abc123")
    end

    it 'raises an error when it fails' do
      file = described_class.new(url: "https://api.github.com/repos/pmfit/git_record/contents/abc123")

      stub_request(:put, "https://api.github.com/repos/pmfit/git_record/contents/abc123")
        .to_return(
          status: 417,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Something went wrong" }.to_json
        )

      expect { file.update("abc123") }.to raise_error(StandardError, "Something went wrong")
    end
  end
end