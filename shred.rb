require 'rmagick'
require 'fileutils'
include Magick

# usage:
# ruby shred.rb <path_to_file> <no of iterations>
# example:
# ruby shred.rb my_image.jpg 1

class Shredder
  attr_accessor :input, :pieces, :input_width, :input_height, :thickness
  def initialize(input)
    @input = input
    @input_width = @input.columns
    @input_height = @input.rows
  end

  def shred(image, pieces)
    @pieces = pieces
    @thickness = @input_width / @pieces

    shredded_pieces = ImageList.new
    @pieces.times do |index|
      x_offset = index * @thickness
      pixels = get_pixels(image, x_offset)
      generated = Image.constitute(@thickness,@input_height,'RGB', pixels)
      shredded_pieces << generated
    end

    shredded_pieces
  end

  def stitch(shredded_pieces)
    odd = ImageList.new()
    even = ImageList.new()

    shredded_pieces.each_with_index do |piece, index|
      if index.odd?
        odd << piece
      else
        even << piece
      end
    end

    new_array = even.concat(odd)

    new_array.each_with_index do |piece, index|
      piece.page = Rectangle.new(thickness, input_height, index * thickness, 0)
      piece.page
    end

    new_array.mosaic
  end

  private

  def get_pixels(image, x_offset)
    image.dispatch(x_offset,0,thickness,input_height,'RGB')
  end
end

input_image = Image.read(ARGV[0]).first
filename = input_image.filename.split('.')[0]
iterations = ARGV[1].to_i
columns = 216
iterations.times do |index|
  unless index == 0
    input_image = Image.read("#{filename}_#{index}_iterations.jpg").first
  end

  shred = Shredder.new(input_image)
  first_shred_pieces = shred.shred(input_image, columns)
  first_stitch = shred.stitch(first_shred_pieces)
  rotated_first_stitch = first_stitch.rotate(90)
  second_shred_pieces = shred.shred(rotated_first_stitch, columns)
  second_stitch = shred.stitch(second_shred_pieces)

  final = second_stitch.rotate(-90)
  final.write("#{filename}_#{index + 1}_iterations.jpg")
end

puts 'done!'
exit