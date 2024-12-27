# frozen_string_literal: true

require_relative 'lib/directory_functions'
require_relative 'lib/pigg_image_functions'

@images_dir = ARGV[0].chomp('/')
@target_dir = "#{@images_dir}/img"

@pigg = PiggImageFunctions.new
@dirfns = DirectoryFunctions.new

images_list = @dirfns.list_image_files(@images_dir)

def ok
  print(" OK\n")
end

def err(msg)
  abort("\nERROR: #{msg}")
end

print "-=> Checking source directory: #{@images_dir} ..."
result = @dirfns.check_directory(@images_dir)
result == 'OK' ? ok : err(result)

print "-=> Creating img directory at #{@target_dir} ..."
result = @dirfns.create_directory(@target_dir)
result ? ok : err("Couldn't create /img directory")

print "-=> Setting up new gallery structure at #{@target_dir} ..."
result = @dirfns.create_image_size_directories(@target_dir)
result ? ok : err("Couldn't create image size directories")

puts '-=> Generating images ...'
images_list.product(@dirfns.image_sizes).each do |img, img_size|
  input_path = "#{@images_dir}/#{img}"
  output_path = "#{@target_dir}/#{img_size}/#{img}"
  result = @pigg.resize_image(input_path, output_path, img_size)
  result ? puts("     ✔ #{output_path}") : puts("     ❌ #{output_path}")
end

print '-=> Generating image manifest for use as a JS var ...'
manifest = @pigg.create_image_manifest(@images_dir, images_list)
manifest.nil? || manifest.empty? ? err('Manifest failed') : ok
puts "\n        var imageData = ["
puts(manifest.map { |e| "          #{e},\n" })
puts "        ]\n\n"
