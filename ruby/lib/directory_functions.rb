# frozen_string_literal: true

require 'fileutils'

# Directory manipulation functions
class DirectoryFunctions
  attr_reader :image_sizes

  def initialize
    @image_sizes = [20, 100, 250, 500]
  end

  def check_directory(dir)
    return "Can't find #{dir}" unless Dir.exist?(dir)
    return "#{dir} is not writable" unless File.writable?(dir)
    return "No images in #{dir}" if list_image_files(dir).empty?
    return 'OK'
  end

  def list_image_files(directory)
    return Dir.entries(directory).select { |f| f =~ /\.(jpg|jpeg|gif|png)$/i }
  end

  def create_directory(dir_path)
    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
    return File.exist?(dir_path)
  end

  def create_image_size_directories(target_dir)
    raise "#{target_dir} is not a directory" unless File.directory?(target_dir)
    size_dirs = @image_sizes.map { |size| "#{target_dir}/#{size}" }
    size_dirs.each do |dir|
      return false unless create_directory(dir)
    end
    return true
  end
end
