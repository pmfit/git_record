require 'rails_helper'

RSpec.describe GitRecord::Configuration do
  before(:each) do
    allow(YAML).to receive(:load).and_return({})
  end
  
  it 'should return the default config' do
    config = described_class.new

    expect(config.github).to eq(OpenStruct.new)
    expect(config.commit).to eq(OpenStruct.new(
      create: "git_record: created file",
      update: "git_record: updated file",
      destroy: "git_record: destroyed file",
      batch: "git_record: batch update"
    ))
    expect(config.markdown).to eq(OpenStruct.new(
      converter: Kramdown::Converter::Html
    ))
  end

  it 'should return the passed in config' do
    config = described_class.new(
      github: {
        access_token: "abc123"
      }
    )

    expect(config.github).to eq(OpenStruct.new(
      access_token: "abc123"
    ))
    expect(config.commit).to eq(OpenStruct.new(
      create: "git_record: created file",
      update: "git_record: updated file",
      destroy: "git_record: destroyed file",
      batch: "git_record: batch update"
    ))
    expect(config.markdown).to eq(OpenStruct.new(
      converter: Kramdown::Converter::Html
    ))
  end

  it 'should return the yaml config' do
    allow(YAML).to receive(:load).and_return({
      github: {
        access_token: "abc123"
      }
    })

    config = described_class.new

    expect(config.github).to eq(OpenStruct.new(
      access_token: "abc123"
    ))
    expect(config.commit).to eq(OpenStruct.new(
      create: "git_record: created file",
      update: "git_record: updated file",
      destroy: "git_record: destroyed file",
      batch: "git_record: batch update"
    ))
    expect(config.markdown).to eq(OpenStruct.new(
      converter: Kramdown::Converter::Html
    ))
  end
end