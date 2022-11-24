# frozen_string_literal: true

require_relative './lib/game'

Game.welcome_message
game = Game.choose_mode
game.play_game
