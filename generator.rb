require 'RMagick'
require 'optparse'

options = {
    letter_count: 5,
    image_count:  20,
    noise:        'UniformNoise',
    text:         nil
}

OptionParser.new do |opts|
  opts.banner = 'Usage img_gen.rb [options]'

  opts.on('-lc', '--letter_count COUNT', 'The number of letters for the image. (Default: 5') do |lc|
    options[:letter_count] = lc.to_i
  end

  opts.on('-ic', '--image-count COUNT', 'The number of images that should be generated. (Default: 20)') do |ic|
    options[:image_count] = ic.to_i
  end

  opts.on('-n', '--noise TYPE', 'The noise function. (Default: UniformNoise)',
          *(Magick.constants.select {|c| c.to_s =~ /.*Noise$/}.map {|c| "   ~> #{c.to_s}"})) do |n|
    options[:noise] = n.to_sym
  end

  opts.on('-t', '--text STRING', 'The content of the image. (disables -lc)') do |text|
    options[:text] = text
  end

  opts.on('-h', '--help', 'Display this help.') do
    puts opts
    exit
  end
end.parse!

def gen_image(options, index)
  if options[:text]
    characters = options[:text].split(//)
  else
    characters = [*('a'..'z'), *('A'..'Z'), *('0'..'9')].sample(options[:letter_count])
  end

  canvas = Magick::Image.new(50 * characters.size, 50)
  gc     = Magick::Draw.new

  characters.each_with_index do |cahr, i|
    gc.pointsize(40)
    gc.font(Dir['fonts/*'].sample)
    gc.text(rand(6..12) + 50 * i, rand(35..43), cahr)
    gc.draw(canvas)
  end

  canvas = canvas.add_noise(Magick.const_get(options[:noise]))
  canvas = canvas.quantize(256, Magick::GRAYColorspace)

  canvas.write("gen/#{characters.join}_#{index}.png")
end

options[:image_count].times do |i|
  gen_image(options, i)
end
