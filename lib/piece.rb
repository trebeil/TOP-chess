# frozen_string_literal: true

# Class for creating chess pieces
class Piece
  attr_reader :type, :color
  attr_accessor :position, :active

  def initialize(type, color, position, active)
    @type = type
    @color = color
    @position = position
    @active = active
  end
end
