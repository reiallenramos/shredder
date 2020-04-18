require 'rmagick'
include Magick

class Shredder
  attr_accessor :input, :pieces, :input_width, :input_height, :thickness
  def initialize(input)
    @input = input
    @input_width = @input.columns
    @input_height = @input.rows
  end

  def shred(pieces)
    @pieces = pieces
    @thickness = @input_width / @pieces

    shredded_pieces = ImageList.new
    @pieces.times do |index|
      pixels = get_pixels(index * @thickness)
      generated = Image.constitute(@thickness,@input_height,'RGB', pixels)
      shredded_pieces << generated
    end

    shredded_pieces
  end

  private

  def get_pixels(x_offset)
    input.dispatch(x_offset,0,thickness,input_height,'RGB')
  end

end
input_image = Image.read(ARGV[0]).first
shred = Shredder.new(input_image)

shredded_pieces = shred.shred(10)

exit