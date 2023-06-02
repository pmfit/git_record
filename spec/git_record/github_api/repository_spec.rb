require "rails_helper"

RSpec.describe GitRecord::GithubApi::Repository do
  it 'validates the presence of an id' do
    repo = described_class.new(name: 'git_record', full_name: 'pmfit/git_record')

    expect(repo.valid?).to be(false)
    expect(repo.errors.full_messages).to eq(["Id can't be blank"])
  end

  it 'validates the presence of an name' do
    repo = described_class.new(id: 'abc123', full_name: 'pmfit/git_record')

    expect(repo.valid?).to be(false)
    expect(repo.errors.full_messages).to eq(["Name can't be blank"])
  end

  it 'validates the presence of a full name' do
    repo = described_class.new(id: 'abc123', name: 'git_record')

    expect(repo.valid?).to be(false)
    expect(repo.errors.full_messages).to eq(["Full name can't be blank"])
  end

  describe '#contents' do    
    before(:each) {
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/contents/")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: [
            { "type": "file" },
            { "type": "directory" }
          ].to_json
        )
    }

    it 'requests the contents' do
      repo = described_class.new(id: 'abc123', name: 'git_record', full_name: 'pmfit/git_record')

      expect(repo.contents('/')).to be()
    end
  end

  describe '#branch' do    
    before(:each) {
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/ref/heads/main")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "ref": "heads/main", "object": { "sha": 'abc123' } }.to_json
        )
    }

    it 'requests the branch' do
      repo = described_class.new(id: 'abc123', name: 'git_record', full_name: 'pmfit/git_record')

      expect(repo.branch('main').ref).to eq("heads/main")
    end
  end
  
  describe '#commit' do
    before(:each) {
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record/git/commits/abc123")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Hello world" }.to_json
        )
    }

    it 'requests the commit' do
      repo = described_class.new(id: 'abc123', name: 'git_record', full_name: 'pmfit/git_record')

      expect(repo.commit('abc123').message).to eq("Hello world")
    end
  end

  describe '#blob' do
    let(:blob) { instance_double(GitRecord::GithubApi::Blob) }
    
    before(:each) {
      expect(GitRecord::GithubApi::Blob).to receive(:find).and_return(blob)
    }

    it 'requests the blob' do
      repo = described_class.new(id: 'abc123', name: 'abc123', full_name: 'abc123')

      expect(repo.blob('abc123')).to be(blob)
    end
  end

  describe '#tag' do
    let(:tag) { instance_double(GitRecord::GithubApi::Tag) }
    
    before(:each) {
      expect(GitRecord::GithubApi::Tag).to receive(:find).and_return(tag)
    }

    it 'requests the blob' do
      repo = described_class.new(id: 'abc123', name: 'abc123', full_name: 'abc123')

      expect(repo.tag('abc123')).to be(tag)
    end
  end

  describe '#tree' do
    let(:tree) { instance_double(GitRecord::GithubApi::Tree) }
    
    before(:each) {
      expect(GitRecord::GithubApi::Tree).to receive(:find).and_return(tree)
    }

    it 'requests the blob' do
      repo = described_class.new(id: 'abc123', name: 'abc123', full_name: 'abc123')

      expect(repo.tree('abc123')).to be(tree)
    end
  end

  describe '#find' do
    it 'finds a repository by name' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record")
        .to_return(
          status: 200,
          headers: { "Content-Type": "application/json" },
          body: { "full_name": "pmfit/git_record" }.to_json
        )
          
      expect(described_class.find("pmfit/git_record")).to be_a(described_class)
      expect(described_class.find("pmfit/git_record").full_name).to eq("pmfit/git_record")
    end

    it 'raises an error when it fails' do
      stub_request(:get, "https://api.github.com/repos/pmfit/git_record")
        .to_return(
          status: 417,
          headers: { "Content-Type": "application/json" },
          body: { "message": "Something went wrong" }.to_json
        )

      expect { described_class.find("pmfit/git_record") }.to raise_error(StandardError, "Something went wrong")
    end
  end
end