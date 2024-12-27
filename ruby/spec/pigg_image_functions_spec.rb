# frozen_string_literal: true

require_relative '../lib/pigg_image_functions'

MANIFEST = [
  '{ "filename": "vn.jpg", "aspectRatio": "1.3300" }',
  '{ "filename": "vn2.jpg", "aspectRatio": "1.6300" }',
  '{ "filename": "vn3.jpg", "aspectRatio": "1.3300" }',
  '{ "filename": "vn4.jpg", "aspectRatio": "1.3300" }'
].freeze

describe 'Image manipulation functions' do
  before(:each) do
    @pigg = PiggImageFunctions.new
  end

  after(:all) do
    Dir.glob('spec/support/temp/**/*') do |file|
      FileUtils.rm_rf(file)
    end
  end

  it 'returns the height of an image' do
    image_path = 'spec/support/monkey.jpg'
    expect(@pigg.image_height(image_path)).to eq 809
  end

  it 'returns the width of an image' do
    image_path = 'spec/support/monkey.jpg'
    expect(@pigg.image_width(image_path)).to eq 798
  end

  it 'returns the aspect ratio of a jpg image' do
    image_path = 'spec/support/monkey.jpg'
    expect(@pigg.aspect_ratio(image_path)).to eq '0.9864'
  end

  it 'returns the aspect ratio of a png image' do
    image_path = 'spec/support/monkey2.png'
    expect(@pigg.aspect_ratio(image_path)).to eq '1.4615'
  end

  it 'resizes and saves a jpg image' do
    input_path = 'spec/support/monkey.jpg'
    output_path = 'spec/support/temp/monkey.jpg'
    new_height = 400
    expect(@pigg.resize_image(input_path, output_path, new_height)).to be true
    expect(@pigg.image_height(output_path)).to eq 400
    expect(@pigg.image_width(output_path)).to eq 395
    expect(@pigg.aspect_ratio(output_path).to_f.round(2))
      .to eq @pigg.aspect_ratio(input_path).to_f.round(2)
  end

  it 'resizes and saves a png image as a jpg' do
    input_path = 'spec/support/monkey2.png'
    output_path = 'spec/support/temp/monkey2.jpg'
    new_height = 400
    expect(@pigg.resize_image(input_path, output_path, new_height)).to be true
  end

  it 'returns an array manifest for a specified dierctory' do
    # To separate concerns, assume we have a valid array of images from
    # DirectoryFunctions::list_image_files
    list_of_image_files = ['vn.jpg', 'vn2.jpg', 'vn3.jpg', 'vn4.jpg']
    project_dir = 'spec/support/project'
    response = @pigg.create_image_manifest(project_dir, list_of_image_files)
    expect(response).to eq MANIFEST
  end
end
