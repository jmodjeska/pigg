# frozen_string_literal: true

require 'mini_magick'

# Image manipulation functions
class PiggImageFunctions
  def image_height(image_path)
    image = MiniMagick::Image.open(image_path)
    return image.height
  end

  def image_width(image_path)
    image = MiniMagick::Image.open(image_path)
    return image.width
  end

  def aspect_ratio(image_path)
    image = MiniMagick::Image.open(image_path)
    width = image.width
    height = image.height
    return format('%.4f', width.to_f / height)
  end

  def resize_image(input_path, output_path, new_height)
    image = MiniMagick::Image.open(input_path)
    image.resize "x#{new_height}"
    image.format 'jpeg'
    image.write output_path
    return File.exist?(output_path)
  end

  def create_image_manifest(directory, list_of_image_files)
    dir = "#{directory}/img/100"
    manifest = []
    list_of_image_files.each do |file|
      ratio = aspect_ratio("#{dir}/#{file}")
      manifest << { 'filename' => file, 'aspectRatio' => ratio }
    end
    return manifest
  end
end
