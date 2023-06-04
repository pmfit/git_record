require 'rails_helper'

RSpec.describe GithubRecord::Base do
  describe "#all" do
    it 'finds all github blobs' do
      file = instance_double(GithubRecord::Base, path: "README.md")
      
      allow(described_class).to receive(:query).and_return([file].lazy)

      expect(described_class.all.count).to eq(1)
      expect(described_class.all.first.path).to eq("README.md")
    end
  end

  describe "#find" do
    it 'finds a github record by path' do
      file = instance_double(GitRecord::GithubApi::File, path: "README.md", decoded_content: 'abc123')
      
      allow(file).to receive(:is_a?).and_return(GitRecord::GithubApi::File)
      allow(GitRecord::GithubApi::Contents).to receive(:find).with("README.md", anything, anything).and_return([file])

      expect(described_class.find("README.md").path).to eq("README.md")
    end
  end

  describe "#find_by" do
    it 'finds a github record by path' do
      file = instance_double(GitRecord::GithubApi::File, path: "README.md", decoded_content: 'abc123')
      
      allow(described_class).to receive(:query).and_return([file].lazy)

      expect(described_class.find_by(path: "README.md").path).to eq("README.md")
    end

    it 'finds a github record by fuzzy path' do
      file = instance_double(GitRecord::GithubApi::File, path: "README.md", decoded_content: 'abc123')
      
      allow(described_class).to receive(:query).and_return([file].lazy)

      expect(described_class.find_by(path: lambda { |path| path.include?("README") } ).path).to eq("README.md")
    end
  end

  describe "#where" do
    it 'finds a github records by path' do
      file = instance_double(GitRecord::GithubApi::File, path: "README.md", decoded_content: 'abc123')
      
      allow(described_class).to receive(:query).and_return([file].lazy)

      expect(described_class.where(path: "README.md").count).to eq(1)
      expect(described_class.where(path: "README.md").first.path).to eq("README.md")
    end

    it 'finds a github record by fuzzy path' do
      file = instance_double(GitRecord::GithubApi::File, path: "README.md", decoded_content: 'abc123')
      
      allow(described_class).to receive(:query).and_return([file].lazy)

      expect(described_class.where(path: lambda { |path| path.include?("README") }).count).to eq(1)
      expect(described_class.where(path: lambda { |path| path.include?("README") } ).first.path).to eq("README.md")
    end
  end
end