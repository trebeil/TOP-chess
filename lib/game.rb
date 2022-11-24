# frozen_string_literal: true

require_relative 'piece'
require_relative 'move'
require 'yaml'

# Class that represents a complete game status
class Game
  attr_reader :player, :moves
  attr_accessor :board

  def initialize
    @player = 'white'
    @board = generate_board
    @moves = []
    @killed = { 'white' => [], 'black' => [] }
  end

  def self.welcome_message
    top = "\u2554"
    60.times { top += "\u2550" }
    top += "\u2557"
    puts top

    puts "\u2551                      \e[1mWelcome to CHESS\e[0m                      \u2551"

    bottom = "\u255A"
    60.times { bottom += "\u2550" }
    bottom += "\u255D"
    puts bottom
  end

  def self.choose_mode
    choice = new_or_load
    create_game(choice)
  end

  def self.new_or_load
    loop do
      puts ' Do you want to start a new game or load a saved game?'
      puts '  [1] Start new game'
      puts '  [2] Load saved game'
      choice = gets.chomp
      return choice if /^[12]{1}$/.match?(choice)

      Game.warning('Invalid choice.')
    end
  end

  def self.create_game(choice)
    if choice == '1'
      Game.new
    elsif choice == '2' && Dir.glob('games/*.yaml').empty?
      puts "\n There are no saved games. Starting new game."
      Game.new
    else
      Game.load_game
    end
  end

  def self.warning(string)
    puts "\e[38;5;196m #{string}\e[0m"
  end

  def generate_board
    hash = { 'a1' => Piece.new('rook', 'white', 'a1', true),
             'b1' => Piece.new('knight', 'white', 'b1', true),
             'c1' => Piece.new('bishop', 'white', 'c1', true),
             'd1' => Piece.new('queen', 'white', 'd1', true),
             'e1' => Piece.new('king', 'white', 'e1', true),
             'f1' => Piece.new('bishop', 'white', 'f1', true),
             'g1' => Piece.new('knight', 'white', 'g1', true),
             'h1' => Piece.new('rook', 'white', 'h1', true),
             'a8' => Piece.new('rook', 'black', 'a8', true),
             'b8' => Piece.new('knight', 'black', 'b8', true),
             'c8' => Piece.new('bishop', 'black', 'c8', true),
             'd8' => Piece.new('queen', 'black', 'd8', true),
             'e8' => Piece.new('king', 'black', 'e8', true),
             'f8' => Piece.new('bishop', 'black', 'f8', true),
             'g8' => Piece.new('knight', 'black', 'g8', true),
             'h8' => Piece.new('rook', 'black', 'h8', true) }

    ('a'..'h').each do |i|
      index = "#{i}2"
      hash[index] = Piece.new('pawn', 'white', index, true)

      index = "#{i}7"
      hash[index] = Piece.new('pawn', 'black', index, true)

      (3..6).each do |j|
        hash["#{i}#{j}"] = nil
      end
    end

    hash
  end

  def self.load_game
    filename = choose_file

    game = ''
    File.open("games/#{filename}.yaml", 'r') do |file|
      game = YAML.safe_load_file(file, permitted_classes: [Game, Move, Piece])
    end

    puts "\n Game successfully loaded!"
    game
  end

  def self.choose_file
    loop do
      puts "\n These are the available games for loading:"

      Dir.glob('games/*.yaml').each do |file|
        puts "\e[3m  - #{file.gsub('games/', '').gsub('.yaml', '')}\e[0m"
      end

      puts "\n What is the name of the game you want to load?"
      filename = gets.chomp
      return filename if File.exist?("games/#{filename}.yaml")

      Game.warning('Invalid name.')
    end
  end

  def play_game
    loop do
      show_board
      show_killed
      show_turn_message

      piece = ''
      destination = ''

      loop do
        piece = choose_piece_or_save
        break if piece == 'save'

        destination = choose_destination
        break if valid_destination?(piece, destination)
      end

      if piece == 'save'
        save_game
        break
      end

      implement_move(piece, destination)
      break if game_over?

      change_player
    end
  end

  def show_board
    o = "\u203E\u203E\u203E\u203E"
    puts '             a    b    c    d    e    f    g    h   '

    (0..7).each do |i|
      puts "           |#{o}|#{o}|#{o}|#{o}|#{o}|#{o}|#{o}|#{o}|"
      puts line_string(8 - i)
    end
    puts "            #{o} #{o} #{o} #{o} #{o} #{o} #{o} #{o} "
    puts '             a    b    c    d    e    f    g    h   '
  end

  def show_killed
    puts "\n\e[1m         LOST PIECES\e[0m"
    black_symbols = @killed['black'].map { |piece| symbol(piece) }
    puts "          BLACK \u21E8 #{black_symbols.join(' - ')}"
    white_symbols = @killed['white'].map { |piece| symbol(piece) }
    puts "          WHITE \u21E8 #{white_symbols.join(' - ')}"
  end

  def show_turn_message
    line = ''
    60.times { line += "\u2550" }
    puts line
    puts "\e[1m                      #{@player.upcase} PLAYER'S TURN\e[0m"
    puts line
  end

  def choose_piece_or_save
    loop do
      puts "\n What piece do you want to move? Type it\'s position (ex: d1). " \
           "Or type 'save' to save and exit the game."
      choice = gets.chomp
      return choice if choice == 'save'
      return @board[choice] if valid_choice?(choice)
    end
  end

  def valid_choice?(position, board = @board)
    if position_format_invalid?(position) || out_of_board?(position, board)
      Game.warning('Invalid choice.')
      false
    elsif board[position].nil?
      Game.warning('Position is empty.')
      false
    elsif board[position].color != @player
      Game.warning("Position has a #{board[position].color} piece. Choose a #{@player} piece.")
      false
    else
      true
    end
  end

  def position_format_invalid?(position)
    !/^[a-z]{1}[0-9]{1}$/.match?(position)
  end

  def out_of_board?(position, board = @board)
    !board.key?(position)
  end

  def choose_destination
    puts "\n Where do you want to move the piece to? Type a destination (ex: d1):"
    gets.chomp
  end

  def valid_destination?(piece, destination, board = @board, check_for_check = true, messages = true)
    if position_format_invalid?(destination) || out_of_board?(destination, board)
      Game.warning('Invalid destination.') if messages == true
      return false
    elsif piece.position == destination
      Game.warning('Destination is the same as origin.') if messages == true
      return false
    elsif !board[destination].nil? && board[destination].color == piece.color
      Game.warning("Destination already has a #{piece.color} piece.") if messages == true
      return false
    end

    result = case piece.type
             when 'pawn' then valid_pawn_move?(piece, destination, board)
             when 'rook' then valid_rook_move?(piece, destination, board)
             when 'knight' then valid_knight_move?(piece, destination)
             when 'bishop' then valid_bishop_move?(piece, destination, board)
             when 'queen' then valid_queen_move?(piece, destination, board)
             when 'king' then valid_king_move?(piece, destination, board)
             end

    if result == false
      Game.warning('Invalid move.') if messages == true
      return false
    end

    new_board = clone_board(board)
    implement_simple_move(new_board[piece.position], destination, new_board)

    if check_for_check == true && king_in_check?(piece.color, new_board)
      Game.warning('Move puts own king in check.') if messages == true
      return false
    end

    result
  end

  def valid_pawn_move?(piece, destination, board = @board)
    condition1 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) == 1 &&
                 destination_empty?(destination, board) == true &&
                 piece.color == 'white'

    condition2 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) == 2 &&
                 destination_empty?(destination, board) == true &&
                 inbetween_empty?(piece, destination, board) == true &&
                 piece.color == 'white' &&
                 piece.position[1] == '2'

    condition3 = column_shift(piece, destination) == 1 &&
                 row_shift(piece, destination) == 1 &&
                 destination_has_opponent?(piece, destination, board) == true &&
                 piece.color == 'white'

    condition4 = column_shift(piece, destination) == -1 &&
                 row_shift(piece, destination) == 1 &&
                 destination_has_opponent?(piece, destination, board) == true &&
                 piece.color == 'white'

    condition5 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) == -1 &&
                 destination_empty?(destination, board) == true &&
                 piece.color == 'black'

    condition6 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) == -2 &&
                 destination_empty?(destination, board) == true &&
                 inbetween_empty?(piece, destination, board) == true &&
                 piece.color == 'black' &&
                 piece.position[1] == '7'

    condition7 = column_shift(piece, destination) == 1 &&
                 row_shift(piece, destination) == -1 &&
                 destination_has_opponent?(piece, destination, board) == true &&
                 piece.color == 'black'

    condition8 = column_shift(piece, destination) == -1 &&
                 row_shift(piece, destination) == -1 &&
                 destination_has_opponent?(piece, destination, board) == true &&
                 piece.color == 'black'

    condition9 = moves[0].nil? ? false : valid_en_passant?(piece, destination)

    if condition1 || condition2 || condition3 || condition4 ||
       condition5 || condition6 || condition7 || condition8 ||
       condition9
      true
    else
      false
    end
  end

  def valid_rook_move?(piece, destination, board = @board)
    condition1 = column_shift(piece, destination) != 0 &&
                 row_shift(piece, destination).zero? &&
                 inbetween_empty?(piece, destination, board)

    condition2 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) != 0 &&
                 inbetween_empty?(piece, destination, board)

    if condition1 || condition2
      true
    else
      false
    end
  end

  def valid_knight_move?(piece, destination)
    condition1 = (column_shift(piece, destination) == 2 ||
                 column_shift(piece, destination) == -2) &&
                 row_shift(piece, destination) == 1

    condition2 = (column_shift(piece, destination) == 2 ||
                 column_shift(piece, destination) == -2) &&
                 row_shift(piece, destination) == -1

    condition3 = (column_shift(piece, destination) == 1 ||
                 column_shift(piece, destination) == -1) &&
                 row_shift(piece, destination) == 2

    condition4 = (column_shift(piece, destination) == 1 ||
                 column_shift(piece, destination) == -1) &&
                 row_shift(piece, destination) == -2

    if condition1 || condition2 || condition3 || condition4
      true
    else
      false
    end
  end

  def valid_bishop_move?(piece, destination, board = @board)
    condition1 = column_shift(piece, destination) == row_shift(piece, destination) &&
                 inbetween_empty?(piece, destination, board) == true

    condition2 = column_shift(piece, destination) == -row_shift(piece, destination) &&
                 inbetween_empty?(piece, destination, board) == true

    if condition1 || condition2
      true
    else
      false
    end
  end

  def valid_queen_move?(piece, destination, board = @board)
    condition1 = column_shift(piece, destination) != 0 &&
                 row_shift(piece, destination).zero? &&
                 inbetween_empty?(piece, destination, board) == true

    condition2 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) != 0 &&
                 inbetween_empty?(piece, destination, board) == true

    condition3 = column_shift(piece, destination) == row_shift(piece, destination) &&
                 inbetween_empty?(piece, destination, board) == true

    condition4 = column_shift(piece, destination) == -row_shift(piece, destination) &&
                 inbetween_empty?(piece, destination, board) == true

    if condition1 || condition2 || condition3 || condition4
      true
    else
      false
    end
  end

  def valid_king_move?(piece, destination, board = @board)
    condition1 = column_shift(piece, destination) == -1 &&
                 row_shift(piece, destination) == 1

    condition2 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) == 1

    condition3 = column_shift(piece, destination) == 1 &&
                 row_shift(piece, destination) == 1

    condition4 = column_shift(piece, destination) == 1 &&
                 row_shift(piece, destination).zero?

    condition5 = column_shift(piece, destination) == 1 &&
                 row_shift(piece, destination) == -1

    condition6 = column_shift(piece, destination).zero? &&
                 row_shift(piece, destination) == -1

    condition7 = column_shift(piece, destination) == -1 &&
                 row_shift(piece, destination) == -1

    condition8 = column_shift(piece, destination) == -1 &&
                 row_shift(piece, destination).zero?

    condition9 = valid_castling?(piece, destination, board)

    if condition1 || condition2 || condition3 || condition4 ||
       condition5 || condition6 || condition7 || condition8 ||
       condition9
      true
    else
      false
    end
  end

  def column_shift(piece, destination)
    origin_column = piece.position[0].ord
    destination_column = destination[0].ord
    destination_column - origin_column
  end

  def row_shift(piece, destination)
    origin_row = piece.position[1].to_i
    destination_row = destination[1].to_i
    destination_row - origin_row
  end

  def destination_empty?(destination, board = @board)
    board[destination].nil?
  end

  def destination_has_opponent?(piece, destination, board = @board)
    !board[destination].nil? && board[destination].color != piece.color
  end

  def inbetween_empty?(piece, destination, board = @board)
    empty = true

    distance = if row_shift(piece, destination).abs > column_shift(piece, destination).abs
                 row_shift(piece, destination).abs
               else
                 column_shift(piece, destination).abs
               end

    return true if distance == 1

    row_start = piece.position[1].to_i

    row_end = destination[1].to_i

    row_iterator = if row_end > row_start
                     1
                   elsif row_end < row_start
                     -1
                   else
                     0
                   end

    column_start = piece.position[0].ord

    column_end = destination[0].ord

    column_iterator = if column_end > column_start
                        1
                      elsif column_end < column_start
                        -1
                      else
                        0
                      end

    (1...distance).each do |i|
      position_to_check = (column_start + i * column_iterator).chr + (row_start + i * row_iterator).to_s
      unless board[position_to_check].nil?
        empty = false
        break
      end
    end

    empty
  end

  def valid_en_passant?(piece, destination, moves = @moves)
    return false unless piece.type == 'pawn'

    condition1 = piece.color == 'white' &&
                 row_shift(piece, destination) == 1 &&
                 column_shift(piece, destination) == 1 &&
                 moves[-1].type == 'pawn' &&
                 moves[-1].color == 'black' &&
                 row_shift(piece, moves[-1].origin) == 2 &&
                 column_shift(piece, moves[-1].origin) == 1 &&
                 row_shift(piece, moves[-1].destination).zero? &&
                 column_shift(piece, moves[-1].destination) == 1

    condition2 = piece.color == 'white' &&
                 row_shift(piece, destination) == 1 &&
                 column_shift(piece, destination) == -1 &&
                 moves[-1].type == 'pawn' &&
                 moves[-1].color == 'black' &&
                 row_shift(piece, moves[-1].origin) == 2 &&
                 column_shift(piece, moves[-1].origin) == -1 &&
                 row_shift(piece, moves[-1].destination).zero? &&
                 column_shift(piece, moves[-1].destination) == -1

    condition3 = piece.color == 'black' &&
                 row_shift(piece, destination) == -1 &&
                 column_shift(piece, destination) == 1 &&
                 moves[-1].type == 'pawn' &&
                 moves[-1].color == 'white' &&
                 row_shift(piece, moves[-1].origin) == -2 &&
                 column_shift(piece, moves[-1].origin) == 1 &&
                 row_shift(piece, moves[-1].destination).zero? &&
                 column_shift(piece, moves[-1].destination) == 1

    condition4 = piece.color == 'black' &&
                 row_shift(piece, destination) == -1 &&
                 column_shift(piece, destination) == -1 &&
                 moves[-1].type == 'pawn' &&
                 moves[-1].color == 'white' &&
                 row_shift(piece, moves[-1].origin) == -2 &&
                 column_shift(piece, moves[-1].origin) == -1 &&
                 row_shift(piece, moves[-1].destination).zero? &&
                 column_shift(piece, moves[-1].destination) == -1

    if condition1 || condition2 || condition3 || condition4
      true
    else
      false
    end
  end

  def valid_castling?(piece, destination, board = @board)
    return false unless piece.type == 'king'

    # returns false unless king is in its original position and destination is
    # one of the two allowed castling positions
    case piece.color
    when 'white' then return false unless piece.position == 'e1' && destination == 'c1' || destination == 'g1'
    when 'black' then return false unless piece.position == 'e8' && destination == 'c8' || destination == 'g8'
    end

    # returns false if either the king or the rook have previously moved during the game
    rook_origin = 'a1' if destination == 'c1'
    rook_origin = 'h1' if destination == 'g1'
    rook_origin = 'a8' if destination == 'c8'
    rook_origin = 'h8' if destination == 'g8'

    return false if @moves.any? do |move|
                      move.type == 'king' && move.color == piece.color ||
                      move.type == 'rook' && move.origin == rook_origin
                    end

    # returns false unless there are no pieces between the king and the rook
    return false unless inbetween_empty?(piece, rook_origin, board)

    # returns false if king is in check or passes through a square that puts him in check
    king_path = %w[e1 d1 c1] if destination == 'c1'
    king_path = %w[e1 f1 g1] if destination == 'g1'
    king_path = %w[e8 d8 c8] if destination == 'c8'
    king_path = %w[e8 f8 g8] if destination == 'g8'

    king_through_check = king_path.any? do |square|
      new_board = clone_board(board)
      implement_simple_move(new_board[piece.position], square, new_board) if piece.position != square
      king_in_check?(piece.color, new_board)
    end

    return false if king_through_check

    true
  end

  def king_in_check?(color, board = @board)
    pieces = pieces(opponent_color(color), board)

    kings_location = kings_location(color, board)

    if pieces.any? { |each_piece| valid_destination?(each_piece, kings_location, board, false, false) }
      true
    else
      false
    end
  end

  def clone_board(board = @board)
    new_board = board.clone
    new_board.each { |key, _value| new_board[key] = board[key].clone }
    new_board
  end

  def implement_move(piece, destination, board = @board)
    if valid_en_passant?(piece, destination)
      register_move(piece, destination)
      implement_en_passant(piece, destination, board)
    elsif valid_castling?(piece, destination, board)
      register_castling(destination)
      implement_castling(piece, destination, board)
    elsif valid_promotion?(piece, destination)
      register_move(piece, destination)
      implement_simple_move(piece, destination, board)
      implement_promotion(piece, destination, board)
    else
      register_move(piece, destination)
      implement_simple_move(piece, destination, board)
    end
  end

  def valid_promotion?(piece, destination)
    piece.type == 'pawn' && piece.color == 'white' && destination[1] == '8' ||
      piece.type == 'pawn' && piece.color == 'black' && destination[1] == '1'
  end

  def implement_promotion(piece, destination, board = @board)
    choice = ''

    loop do
      puts "\n What do you want to promote the pawn to?"
      puts '  Type 1 for bishop'
      puts '  Type 2 for knight'
      puts '  Type 3 for queen'
      puts '  Type 4 for rook'
      choice = gets.chomp
      break if /^[1-4]$/.match?(choice)

      Game.warning('Invalid choice.')
    end

    type = case choice
           when '1' then 'bishop'
           when '2' then 'knight'
           when '3' then 'queen'
           when '4' then 'rook'
           end

    piece.active = false
    piece.position = nil
    board[destination] = Piece.new(type, piece.color, destination, true)
  end

  def register_move(piece, destination, moves = @moves)
    move = Move.new(piece.type, piece.color, piece.position, destination)
    moves << move
  end

  def register_castling(destination, moves = @moves)
    case destination
    when 'g1'
      move1 = Move.new('king', 'white', 'e1', 'g1')
      move2 = Move.new('rook', 'white', 'h1', 'f1')
      moves << move1
      moves << move2
    when 'c1'
      move1 = Move.new('king', 'white', 'e1', 'c1')
      move2 = Move.new('rook', 'white', 'a1', 'd1')
      moves << move1
      moves << move2
    when 'g8'
      move1 = Move.new('king', 'white', 'e8', 'g8')
      move2 = Move.new('rook', 'white', 'h8', 'f8')
      moves << move1
      moves << move2
    when 'c8'
      move1 = Move.new('king', 'white', 'e8', 'c8')
      move2 = Move.new('rook', 'white', 'a8', 'd8')
      moves << move1
      moves << move2
    end
  end

  def implement_en_passant(piece, destination, board = @board)
    origin = piece.position

    if piece.color == 'white' && column_shift(piece, destination) == 1
      destination = (origin[0].ord + 1).chr + (origin[1].to_i + 1).to_s
      victim_position = (origin[0].ord + 1).chr + origin[1]
    elsif piece.color == 'white' && column_shift(piece, destination) == -1
      destination = (origin[0].ord - 1).chr + (origin[1].to_i + 1).to_s
      victim_position = (origin[0].ord - 1).chr + origin[1]
    elsif piece.color == 'black' && column_shift(piece, destination) == 1
      destination = (origin[0].ord + 1).chr + (origin[1].to_i - 1).to_s
      victim_position = (origin[0].ord + 1).chr + origin[1]
    elsif piece.color == 'black' && column_shift(piece, destination) == -1
      destination = (origin[0].ord - 1).chr + (origin[1].to_i - 1).to_s
      victim_position = (origin[0].ord - 1).chr + origin[1]
    end

    @killed[opponent_color(piece.color)] << board[victim_position]
    board[victim_position].active = false
    board[victim_position].position = nil
    board[victim_position] = nil
    board[destination] = piece
    piece.position = destination
    board[origin] = nil
  end

  def implement_castling(king, destination, board = @board)
    case destination
    when 'g1'
      rook = board['h1']
      board['g1'] = king
      board['e1'] = nil
      board['f1'] = rook
      board['h1'] = nil
      king.position = 'g1'
      rook.position = 'f1'
    when 'c1'
      rook = board['a1']
      board['c1'] = king
      board['e1'] = nil
      board['d1'] = rook
      board['a1'] = nil
      king.position = 'c1'
      rook.position = 'd1'
    when 'g8'
      rook = board['h8']
      board['g8'] = king
      board['e8'] = nil
      board['f8'] = rook
      board['h8'] = nil
      king.position = 'g8'
      rook.position = 'f8'
    when 'c8'
      rook = board['a8']
      board['c8'] = king
      board['e8'] = nil
      board['d8'] = rook
      board['a8'] = nil
      king.position = 'c8'
      rook.position = 'd8'
    end
  end

  def implement_simple_move(piece, destination, board = @board)
    origin = piece.position

    unless board[destination].nil?
      @killed[opponent_color(piece.color)] << board[destination] if board == @board
      board[destination].active = false
      board[destination].position = nil
    end

    board[destination] = piece
    piece.position = destination
    board[origin] = nil
  end

  def pieces(color, board = @board)
    board.filter_map do |_key, value|
      value if !value.nil? && value.color == color
    end
  end

  def kings_location(color, board = @board)
    pieces = board.filter { |_key, value| !value.nil? }

    king_piece = pieces.find { |_key, value| value.color == color && value.type == 'king' }

    king_piece[1].position
  end

  def change_player
    @player = opponent_color(@player)
  end

  def opponent_color(color)
    case color
    when 'white' then 'black'
    when 'black' then 'white'
    end
  end

  def symbol(piece)
    return ' ' if piece.nil?

    type = piece.type
    color = piece.color

    return "\u2654" if type == 'king' && color == 'black'
    return "\u2655" if type == 'queen' && color == 'black'
    return "\u2656" if type == 'rook' && color == 'black'
    return "\u2657" if type == 'bishop' && color == 'black'
    return "\u2658" if type == 'knight' && color == 'black'
    return "\u2659" if type == 'pawn' && color == 'black'
    return "\u265A" if type == 'king' && color == 'white'
    return "\u265B" if type == 'queen' && color == 'white'
    return "\u265C" if type == 'rook' && color == 'white'
    return "\u265D" if type == 'bishop' && color == 'white'
    return "\u265E" if type == 'knight' && color == 'white'
    return "\u265F" if type == 'pawn' && color == 'white'
  end

  def line_string(number)
    n = number.to_s
    "         #{n} " \
      "| #{symbol(@board["a#{n}"])}  " \
      "| #{symbol(@board["b#{n}"])}  " \
      "| #{symbol(@board["c#{n}"])}  " \
      "| #{symbol(@board["d#{n}"])}  " \
      "| #{symbol(@board["e#{n}"])}  " \
      "| #{symbol(@board["f#{n}"])}  " \
      "| #{symbol(@board["g#{n}"])}  " \
      "| #{symbol(@board["h#{n}"])}  |"
  end

  def game_over?
    puts "\n"

    if check?(opponent_color(@player))
      puts "\e[1;38;5;226m CHECK - #{opponent_color(@player).capitalize} king is under attack!\e[0m\n"
      false
    elsif checkmate?(opponent_color(@player))
      puts "\e[1;5;38;5;27m CHECKMATE - #{@player.capitalize} player wins!\e[0m\n"
      true
    elsif stalemate?(opponent_color(@player))
      puts "\e[1m IT'S A DRAW - #{opponent_color(@player).capitalize} is not in check
        and has no legal move available.\e[0m\n"
      true
    elsif only_kings?
      puts "\e[1m IT'S A DRAW - Only kings are left on the board.\e[0m\n"
      true
    else
      false
    end
  end

  def has_legal_move?(color, board = @board)
    pieces = pieces(color, board)

    squares = board.map { |key, _value| key }

    has_legal_move = false

    squares.any? { |square| valid_destination?(pieces[0], square, board, true, false) }

    pieces.each do |piece|
      has_legal_move = true if squares.any? { |square| valid_destination?(piece, square, board, true, false) }
    end

    has_legal_move
  end

  def only_kings?(board = @board)
    pieces = pieces('white', board) + pieces('black', board)

    pieces.all? { |piece| piece.type == 'king' }
  end

  def check?(color)
    king_in_check?(color) == true && has_legal_move?(color) == true
  end

  def checkmate?(color)
    king_in_check?(color) == true && has_legal_move?(color) == false
  end

  def stalemate?(color)
    king_in_check?(color) == false && has_legal_move?(color) == false
  end

  def save_game
    filename = choose_filename

    Dir.mkdir('games') unless Dir.exist?('games')

    File.open("games/#{filename}.yaml", 'w') do |file|
      YAML.dump(self, file)
    end

    puts "\n Game successfully saved."
  end

  def choose_filename
    loop do
      overwrite = 'y'
      puts "\n What is the filename you want to use to save the game? Use only letters and numbers."
      filename = gets.chomp
      if File.exist?("games/#{filename}.yaml")
        loop do
          puts "\n Filename already exists. Overwrite existing file? (y/n)"
          overwrite = gets.chomp
          break if /^[yn]{1}$/.match?(overwrite)

          Game.warning('Invalid choice.')
        end
      end
      return filename if /^[a-zA-Z0-9]+$/.match?(filename) && overwrite == 'y'

      Game.warning('Invalid name.') unless /^[a-zA-Z0-9]+$/.match?(filename)
    end
  end
end
