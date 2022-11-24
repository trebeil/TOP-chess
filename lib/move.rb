# frozen_string_literal: true

# Class for registering a move made during the game
class Move
  attr_reader :type, :color, :origin, :destination

  def initialize(type, color, origin, destination)
    @type = type
    @color = color
    @origin = origin
    @destination = destination
  end
end
