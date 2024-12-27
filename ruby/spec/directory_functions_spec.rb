# frozen_string_literal: true

require_relative '../lib/directory_functions'

describe 'Directory functions' do
  before(:each) do
    @dirfns = DirectoryFunctions.new
  end

  after(:all) do
    Dir.glob('spec/support/temp/**/*') do |file|
      FileUtils.rm_rf(file)
    end
  end

  it 'lists image files in a directory' do
    files = @dirfns.list_image_files('spec/support')
    expect(files.sort).to eq ['monkey.jpg', 'monkey2.png']
  end

  it 'returns an error if the directory does not exist' do
    expect(@dirfns.check_directory('spec/support/hippo')).to include "Can't find"
  end

  it 'returns an error if the directory is not writable' do
    response = @dirfns.check_directory('spec/support/locked_dir_chmod_400')
    expect(response).to include 'not writable'
  end

  it 'returns an error if the directory does not exist' do
    response = @dirfns.check_directory('spec/support/empty_dir')
    expect(response).to include 'No images'
  end

  it 'returns OK for a writable directory with images' do
    response = @dirfns.check_directory('spec/support/good_dir')
    expect(response).to eq 'OK'
  end

  it 'creates a directory' do
    response = @dirfns.create_directory('spec/support/temp/test_dir')
    expect(response).to be true
  end

  it 'creates the target directory structure' do
    @dirfns.create_directory('spec/support/temp/project')
    temp_project = 'spec/support/temp/project'
    Dir.glob('spec/support/good_dir/**.*').each do |file|
      FileUtils.cp(file, temp_project) if File.file?(file)
    end
    expect(@dirfns.create_image_size_directories(temp_project)).to be true
    expect(File.exist?('spec/support/temp/project/100')).to be true
  end
end
