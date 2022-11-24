# frozen_string_literal: true

require_relative '../lib/game'

describe Game do
  subject(:game) { described_class.new }

  describe '#generate_board' do
    context 'when a new board is generated' do
      it 'positions a white active knight on square b1' do
        board = game.generate_board
        expect(board['b1'].type).to eq('knight')
        expect(board['b1'].color).to eq('white')
        expect(board['b1'].position).to eq('b1')
        expect(board['b1'].active).to eq(true)
      end

      it 'positions a white active bishop on square f1' do
        board = game.generate_board
        expect(board['f1'].type).to eq('bishop')
        expect(board['f1'].color).to eq('white')
        expect(board['f1'].position).to eq('f1')
        expect(board['f1'].active).to eq(true)
      end

      it 'positions a white active pawn on square d2' do
        board = game.generate_board
        expect(board['d2'].type).to eq('pawn')
        expect(board['d2'].color).to eq('white')
        expect(board['d2'].position).to eq('d2')
        expect(board['d2'].active).to eq(true)
      end

      it 'positions nil on square c3' do
        board = game.generate_board
        expect(board['c3']).to eq(nil)
      end

      it 'positions nil on square c4' do
        board = game.generate_board
        expect(board['c4']).to eq(nil)
      end

      it 'positions nil on square c5' do
        board = game.generate_board
        expect(board['c5']).to eq(nil)
      end

      it 'positions nil on square c6' do
        board = game.generate_board
        expect(board['c6']).to eq(nil)
      end

      it 'positions a black active pawn on square f7' do
        board = game.generate_board
        expect(board['f7'].type).to eq('pawn')
        expect(board['f7'].color).to eq('black')
        expect(board['f7'].position).to eq('f7')
        expect(board['f7'].active).to eq(true)
      end

      it 'positions a black active queen on square d8' do
        board = game.generate_board
        expect(board['d8'].type).to eq('queen')
        expect(board['d8'].color).to eq('black')
        expect(board['d8'].position).to eq('d8')
        expect(board['d8'].active).to eq(true)
      end

      it 'positions a black active rook on square h8' do
        board = game.generate_board
        expect(board['h8'].type).to eq('rook')
        expect(board['h8'].color).to eq('black')
        expect(board['h8'].position).to eq('h8')
        expect(board['h8'].active).to eq(true)
      end
    end
  end

  describe '#choose_piece' do
    context 'when player white tries to choose a piece that does not belong to him,
             then an empty square, then a position that does not exist,
             then a valid piece' do
      before do
        allow(game).to receive(:gets).and_return('d8', 'b4', '7', 'h1')
        game.instance_variable_set(:@board, { 'd8' => instance_double(Piece, type: 'queen',
                                                                             color: 'black',
                                                                             position: 'd8',
                                                                             active: true),
                                              'b4' => nil,
                                              'h1' => instance_double(Piece, type: 'rook',
                                                                             color: 'white',
                                                                             position: 'h1',
                                                                             active: true) })
      end

      it 'displays error messages in sequence' do
        first_message = "\n What piece do you want to move? Type it's position (ex: d1). " \
          "Or type 'save' to save and exit the game."
        error_message1 = "\e[38;5;196m Position has a black piece. Choose a white piece.\e[0m"
        error_message2 = "\e[38;5;196m Position is empty.\e[0m"
        error_message3 = "\e[38;5;196m Invalid choice.\e[0m"
        expect(game).to receive(:puts).with(first_message).exactly(4).times
        expect(Game).to receive(:puts).with(error_message1)
        expect(Game).to receive(:puts).with(error_message2)
        expect(Game).to receive(:puts).with(error_message3)
        game.choose_piece_or_save
      end

      it 'calls gets four times' do
        expect(game).to receive(:gets).exactly(4).times
        game.choose_piece_or_save
      end

      it 'returns the valid piece' do
        target = game.instance_variable_get(:@board)['h1']
        piece = game.choose_piece_or_save
        expect(piece).to eq(target)
      end
    end
  end

  describe '#row_shift' do
    context 'when piece in a1, destination in a8' do
      it 'returns 7' do
        piece = instance_double(Piece, position: 'a1')
        destination = 'a8'
        result = game.row_shift(piece, destination)
        expect(result).to eq(7)
      end
    end

    context 'when piece in a8, destination in a1' do
      it 'returns -7' do
        piece = instance_double(Piece, position: 'a8')
        destination = 'a1'
        result = game.row_shift(piece, destination)
        expect(result).to eq(-7)
      end
    end

    context 'when piece in a1, destination in c5' do
      it 'returns 4' do
        piece = instance_double(Piece, position: 'a1')
        destination = 'c5'
        result = game.row_shift(piece, destination)
        expect(result).to eq(4)
      end
    end

    context 'when piece in h8, destination in e5' do
      it 'returns -3' do
        piece = instance_double(Piece, position: 'h8')
        destination = 'e5'
        result = game.row_shift(piece, destination)
        expect(result).to eq(-3)
      end
    end
  end

  describe '#column_shift' do
    context 'when piece in a1, destination in h8' do
      it 'returns 7' do
        piece = instance_double(Piece, position: 'a1')
        destination = 'h8'
        result = game.column_shift(piece, destination)
        expect(result).to eq(7)
      end
    end

    context 'when piece in a8, destination in a1' do
      it 'returns 0' do
        piece = instance_double(Piece, position: 'a8')
        destination = 'a1'
        result = game.column_shift(piece, destination)
        expect(result).to eq(0)
      end
    end

    context 'when piece in a1, destination in c5' do
      it 'returns 2' do
        piece = instance_double(Piece, position: 'a1')
        destination = 'c5'
        result = game.column_shift(piece, destination)
        expect(result).to eq(2)
      end
    end

    context 'when piece in h8, destination in e5' do
      it 'returns -3' do
        piece = instance_double(Piece, position: 'h8')
        destination = 'e5'
        result = game.column_shift(piece, destination)
        expect(result).to eq(-3)
      end
    end
  end

  describe '#inbetween_empty?' do
    context 'when piece in a1, destination in a8 and no piece inbetween' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => nil,
                                              'a6' => nil,
                                              'a7' => nil,
                                              'a8' => nil })
        destination = 'a8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in a8 and one piece inbetween' do
      it 'returns false' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'a5')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => piece2,
                                              'a6' => nil,
                                              'a7' => nil,
                                              'a8' => nil })
        destination = 'a8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when piece in a1, destination in h1 and no piece inbetween' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b1' => nil,
                                              'c1' => nil,
                                              'd1' => nil,
                                              'e1' => nil,
                                              'f1' => nil,
                                              'g1' => nil,
                                              'h1' => nil })
        destination = 'h1'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in h1 and one piece inbetween' do
      it 'returns false' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'e1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b1' => nil,
                                              'c1' => nil,
                                              'd1' => nil,
                                              'e1' => piece2,
                                              'f1' => nil,
                                              'g1' => nil,
                                              'h1' => nil })
        destination = 'h1'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when piece in a1, destination in h8 and no piece inbetween' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => nil,
                                              'e5' => nil,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        destination = 'h8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in h1 and one piece inbetween' do
      it 'returns false' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'e5')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => nil,
                                              'e5' => piece2,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        destination = 'h8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when piece in a8, destination in a1 and no piece inbetween' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a8')
        game.instance_variable_set(:@board, { 'a1' => nil,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => nil,
                                              'a6' => nil,
                                              'a7' => nil,
                                              'a8' => piece })
        destination = 'a1'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in a8 and one piece inbetween' do
      it 'returns false' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'a5')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => piece2,
                                              'a6' => nil,
                                              'a7' => nil,
                                              'a8' => nil })
        destination = 'a8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when piece in a1, destination in h1 and no piece inbetween' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b1' => nil,
                                              'c1' => nil,
                                              'd1' => nil,
                                              'e1' => nil,
                                              'f1' => nil,
                                              'g1' => nil,
                                              'h1' => nil })
        destination = 'h1'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in h1 and one piece inbetween' do
      it 'returns false' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'e1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b1' => nil,
                                              'c1' => nil,
                                              'd1' => nil,
                                              'e1' => piece2,
                                              'f1' => nil,
                                              'g1' => nil,
                                              'h1' => nil })
        destination = 'h1'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when piece in a1, destination in h8 and no piece inbetween' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => nil,
                                              'e5' => nil,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        destination = 'h8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in h1 and one piece inbetween' do
      it 'returns false' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'e5')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => nil,
                                              'e5' => piece2,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        destination = 'h8'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when piece in a1, destination in a2, destination empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => nil,
                                              'a6' => nil,
                                              'a7' => nil,
                                              'a8' => nil })
        destination = 'a2'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in a1, destination in a2, destination not empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'a1')
        piece2 = instance_double(Piece, position: 'a2')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => piece2,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => nil,
                                              'a6' => nil,
                                              'a7' => nil,
                                              'a8' => nil })
        destination = 'a2'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in e5, destination in d4, destination empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'e5')
        game.instance_variable_set(:@board, { 'a1' => nil,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => nil,
                                              'e5' => piece,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        destination = 'd4'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece in e5, destination in d4, destination not empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'e5')
        piece2 = instance_double(Piece, position: 'd4')
        game.instance_variable_set(:@board, { 'a1' => nil,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => piece2,
                                              'e5' => piece,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        destination = 'd4'
        result = game.inbetween_empty?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when board in the following configuration and black rook trying to
             attack opponent king' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1', :position= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e2', :position= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e4', :position= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6', :position= => nil)
        destination = 'e1'
        game.instance_variable_set(:@board, { 'c6' => black_king,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'e1' => white_king,
                                              'e2' => white_rook,
                                              'e3' => nil,
                                              'e4' => black_rook })
        board = game.instance_variable_get(:@board)
        result = game.inbetween_empty?(black_rook, destination, board)
        expect(result).to eq(false)
      end
    end
  end

  describe '#destination_empty' do
    context 'when destination is empty' do
      it 'returns true' do
        game.instance_variable_set(:@board, { 'e5' => nil })
        destination = 'e5'
        result = game.destination_empty?(destination)
        expect(result).to eq(true)
      end
    end

    context 'when destination is not empty' do
      it 'returns false' do
        piece = instance_double(Piece)
        game.instance_variable_set(:@board, { 'e5' => piece })
        destination = 'e5'
        result = game.destination_empty?(destination)
        expect(result).to eq(false)
      end
    end
  end

  describe '#destination_has_opponent' do
    context 'when destination has opponent' do
      it 'returns true' do
        piece = instance_double(Piece, color: 'white')
        piece2 = instance_double(Piece, color: 'black')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => piece2 })
        destination = 'a2'
        result = game.destination_has_opponent?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when destination has a piece of the same color' do
      it 'returns false' do
        piece = instance_double(Piece, color: 'white')
        piece2 = instance_double(Piece, color: 'white')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => piece2 })
        destination = 'a2'
        result = game.destination_has_opponent?(piece, destination)
        expect(result).to eq(false)
      end
    end

    context 'when destination is empty' do
      it 'returns false' do
        piece = instance_double(Piece, color: 'white')
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil })
        destination = 'a2'
        result = game.destination_has_opponent?(piece, destination)
        expect(result).to eq(false)
      end
    end
  end

  describe '#valid_destination?' do
    context 'when destination format is invalid (1)' do
      let(:piece) { instance_double(Piece) }
      let(:destination) { '1' }

      before do
        game.instance_variable_set(:@board, { 'a1' => nil })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays invalid format message' do
        error_message = "\e[38;5;196m Invalid destination.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when destination format is invalid (a)' do
      let(:piece) { instance_double(Piece) }
      let(:destination) { 'a' }

      before do
        game.instance_variable_set(:@board, { 'a1' => nil })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays invalid format message' do
        error_message = "\e[38;5;196m Invalid destination.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when destination format is invalid (A2)' do
      let(:piece) { instance_double(Piece) }
      let(:destination) { 'A2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => nil })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays invalid format message' do
        error_message = "\e[38;5;196m Invalid destination.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when destination format is invalid (a20)' do
      let(:piece) { instance_double(Piece) }
      let(:destination) { 'a20' }

      before do
        game.instance_variable_set(:@board, { 'a1' => nil })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays invalid format message' do
        error_message = "\e[38;5;196m Invalid destination.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when destination is out of board (j1)' do
      let(:piece) { instance_double(Piece) }
      let(:destination) { 'j1' }

      before do
        game.instance_variable_set(:@board, { 'a1' => nil })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays out of board message' do
        error_message = "\e[38;5;196m Invalid destination.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when destination is out of board (a9)' do
      let(:piece) { instance_double(Piece) }
      let(:destination) { 'a9' }

      before do
        game.instance_variable_set(:@board, { 'a1' => nil })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays out of board message' do
        error_message = "\e[38;5;196m Invalid destination.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when destination is equal to origin' do
      let(:piece) { instance_double(Piece, position: 'a1') }
      let(:destination) { 'a1' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'same as origin\' message' do
        error_message = "\e[38;5;196m Destination is the same as origin.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when piece on destination has the same color as piece trying to be moved - white' do
      let(:piece) { instance_double(Piece, type: 'rook', position: 'a1', color: 'white') }
      let(:piece2) { instance_double(Piece, position: 'a2', color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => piece2 })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'already has piece\' message' do
        error_message = "\e[38;5;196m Destination already has a white piece.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'when piece on destination has the same color as piece trying to be moved - black' do
      let(:piece) { instance_double(Piece, type: 'rook', position: 'a1', color: 'black') }
      let(:piece2) { instance_double(Piece, position: 'a2', color: 'black') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => piece2 })
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'already has piece\' message' do
        error_message = "\e[38;5;196m Destination already has a black piece.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but piece is pawn and valid_pawn_move? is false' do
      let(:piece) { instance_double(Piece, type: 'pawn', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_pawn_move?).and_return(false)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'invalid move\' message' do
        error_message = "\e[38;5;196m Invalid move.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but piece is rook and valid_rook_move? is false' do
      let(:piece) { instance_double(Piece, type: 'rook', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_rook_move?).and_return(false)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'invalid move\' message' do
        error_message = "\e[38;5;196m Invalid move.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but piece is knight and valid_knight_move? is false' do
      let(:piece) { instance_double(Piece, type: 'knight', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_knight_move?).and_return(false)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'invalid move\' message' do
        error_message = "\e[38;5;196m Invalid move.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but piece is bishop and valid_bishop_move? is false' do
      let(:piece) { instance_double(Piece, type: 'bishop', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_bishop_move?).and_return(false)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'invalid move\' message' do
        error_message = "\e[38;5;196m Invalid move.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but piece is queen and valid_queen_move? is false' do
      let(:piece) { instance_double(Piece, type: 'queen', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_queen_move?).and_return(false)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'invalid move\' message' do
        error_message = "\e[38;5;196m Invalid move.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but piece is king and valid_king_move? is false' do
      let(:piece) { instance_double(Piece, type: 'king', position: 'a1', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => nil })
        allow(game).to receive(:valid_king_move?).and_return(false)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'invalid move\' message' do
        error_message = "\e[38;5;196m Invalid move.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, but check_for_check == true and king_in_check is true' do
      let(:piece) { instance_double(Piece, type: 'queen', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_queen_move?).and_return(true)
        allow(game).to receive(:king_in_check?).and_return(true)
      end

      it 'returns false' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(false)
      end

      it 'displays \'own king in check\' message' do
        error_message = "\e[38;5;196m Move puts own king in check.\e[0m"
        expect(Game).to receive(:puts).with(error_message)
        game.valid_destination?(piece, destination)
      end
    end

    context 'piece is pawn and valid_pawn_move? is true' do
      let(:piece) { instance_double(Piece, type: 'pawn', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_pawn_move?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination)
      end
    end

    context 'piece is rook and valid_rook_move? is true' do
      let(:piece) { instance_double(Piece, type: 'rook', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_rook_move?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination)
      end
    end

    context 'piece is knight and valid_knight_move? is true' do
      let(:piece) { instance_double(Piece, type: 'knight', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_knight_move?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination)
      end
    end

    context 'piece is bishop and valid_bishop_move? is true' do
      let(:piece) { instance_double(Piece, type: 'bishop', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_bishop_move?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination)
      end
    end

    context 'piece is queen and valid_queen_move? is true' do
      let(:piece) { instance_double(Piece, type: 'queen', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_queen_move?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination)
      end
    end

    context 'piece is king and valid_king_move? is true' do
      let(:piece) { instance_double(Piece, type: 'king', position: 'a1', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => nil })
        allow(game).to receive(:valid_king_move?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination)
      end
    end

    context 'all above valid, check_for_check == false and king_in_check is true' do
      let(:piece) { instance_double(Piece, type: 'queen', position: 'a1', :position= => nil, color: 'white') }
      let(:king_piece) { instance_double(Piece, type: 'king', position: 'a3', :position= => nil, color: 'white') }
      let(:destination) { 'a2' }
      let(:board) { game.instance_variable_get(:@board) }

      before do
        game.instance_variable_set(:@board, { 'a1' => piece,
                                              'a2' => nil,
                                              'a3' => king_piece })
        allow(game).to receive(:valid_queen_move?).and_return(true)
        allow(game).to receive(:king_in_check?).and_return(true)
      end

      it 'returns true' do
        result = game.valid_destination?(piece, destination, board, false)
        expect(result).to eq(true)
      end

      it 'displays no error message' do
        expect(game).not_to receive(:puts)
        game.valid_destination?(piece, destination, board, false)
      end
    end

    context 'when board in the following configuration and black rook trying to
             attack opponent king' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1', :position= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e2', :position= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e4', :position= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6', :position= => nil)
        destination = 'e1'
        game.instance_variable_set(:@board, { 'c6' => black_king,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'e1' => white_king,
                                              'e2' => white_rook,
                                              'e3' => nil,
                                              'e4' => black_rook })
        board = game.instance_variable_get(:@board)
        result = game.valid_destination?(black_rook, destination, board, true)
        expect(result).to eq(false)
      end
    end

    context 'when board in the following configuration and white rook trying to
             attack opponent king' do
      it 'returns true' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1',
                                            :position= => nil, :active= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e6',
                                            :position= => nil, :active= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e7',
                                            :position= => nil, :active= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6',
                                            :position= => nil, :active= => nil)
        destination = 'c6'
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => white_rook,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd3' => nil })
        board = game.instance_variable_get(:@board)
        result = game.valid_destination?(white_rook, destination, board, false)
        expect(result).to eq(true)
      end
    end
  end

  describe '#out_of_board?' do
    context 'when destination and board in the following configuration' do
      it 'returns false' do
        destination = 'c6'
        game.instance_variable_set(:@board, { 'e1' => nil,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => nil,
                                              'c6' => nil,
                                              'd3' => nil })
        result = game.out_of_board?(destination)
        expect(result).to eq(false)
      end
    end
  end

  describe '#valid_pawn_move?' do
    context 'piece is white and moves up one step and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'c2')
        game.instance_variable_set(:@board, { 'c2' => piece,
                                              'c3' => nil })
        destination = 'c3'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is white and is in line 2 and moves up two steps and destination
     is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'c2')
        game.instance_variable_set(:@board, { 'c2' => piece,
                                              'c3' => nil,
                                              'c4' => nil })
        destination = 'c4'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is white and moves one step up and one step right and destination
             has an opponent piece' do
      it 'returns true' do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'c2')
        piece2 = instance_double(Piece, color: 'black', position: 'd3')
        game.instance_variable_set(:@board, { 'c2' => piece,
                                              'd3' => piece2 })
        destination = 'd3'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is white and moves one step up and one step left and destination has an opponent piece' do
      it 'returns true' do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'c2')
        piece2 = instance_double(Piece, color: 'black', position: 'b3')
        game.instance_variable_set(:@board, { 'c2' => piece,
                                              'b3' => piece2 })
        destination = 'b3'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is black and moves down one step and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'black', position: 'd7')
        game.instance_variable_set(:@board, { 'd7' => piece,
                                              'd6' => nil })
        destination = 'd6'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is black and is in line 7 and moves down two steps and and destination
     is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'black', position: 'd7')
        game.instance_variable_set(:@board, { 'd7' => piece,
                                              'd6' => nil,
                                              'd5' => nil })
        destination = 'd5'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is black and moves one step down and one step right and destination has an opponent piece' do
      it 'returns true' do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        piece = instance_double(Piece, type: 'pawn', color: 'black', position: 'd7')
        piece2 = instance_double(Piece, color: 'white', position: 'e6')
        game.instance_variable_set(:@board, { 'd7' => piece,
                                              'e6' => piece2 })
        destination = 'e6'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'piece is black and moves one step down and one step left and destination has an opponent piece' do
      it 'returns true' do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        piece = instance_double(Piece, type: 'pawn', color: 'black', position: 'd7')
        piece2 = instance_double(Piece, color: 'white', position: 'c6')
        game.instance_variable_set(:@board, { 'd7' => piece,
                                              'c6' => piece2 })
        destination = 'c6'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when valid en passant move' do
      it 'returns true' do
        last_move = instance_double(Move, type: 'pawn', color: 'black',
                                          origin: 'g7', destination: 'g5')
        game.instance_variable_set(:@moves, [last_move])
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'f5')
        game.instance_variable_set(:@board, { 'f5' => piece })
        destination = 'g6'
        result = game.valid_pawn_move?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_rook_move?' do
    context 'moves horizontally and destination is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'h5'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e5' => nil,
                                              'f5' => nil,
                                              'g5' => nil,
                                              'h5' => nil })
        result = game.valid_rook_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves horizontally and destination has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'h5', color: 'black')
        destination = 'h5'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e5' => nil,
                                              'f5' => nil,
                                              'g5' => nil,
                                              'h5' => piece2 })
        result = game.valid_rook_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves vertically and destination is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'd1'
        game.instance_variable_set(:@board, { 'd1' => nil,
                                              'd2' => nil,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'd5' => piece })
        result = game.valid_rook_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves vertically and destination has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'd1', color: 'black')
        destination = 'd1'
        game.instance_variable_set(:@board, { 'd1' => piece2,
                                              'd2' => nil,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'd5' => piece })
        result = game.valid_rook_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when board in the following configuration and black rook trying to
             attack opponent king' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1', :position= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e2', :position= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e4', :position= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6', :position= => nil)
        destination = 'e1'
        game.instance_variable_set(:@board, { 'c6' => black_king,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'e1' => white_king,
                                              'e2' => white_rook,
                                              'e3' => nil,
                                              'e4' => black_rook })
        board = game.instance_variable_get(:@board)
        result = game.valid_rook_move?(black_rook, destination, board)
        expect(result).to eq(false)
      end
    end

    context 'when board in the following configuration and black rook trying to
             move one square left' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1', :position= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e2', :position= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e4', :position= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6', :position= => nil)
        destination = 'd4'
        game.instance_variable_set(:@board, { 'c6' => black_king,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'e1' => white_king,
                                              'e2' => white_rook,
                                              'e3' => nil,
                                              'e4' => black_rook })
        board = game.instance_variable_get(:@board)
        result = game.valid_rook_move?(black_rook, destination, board)
        expect(result).to eq(true)
      end
    end

    context 'when board in the following configuration and black rook trying to
             move one square diagonally' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1', :position= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e2', :position= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e4', :position= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6', :position= => nil)
        destination = 'd3'
        game.instance_variable_set(:@board, { 'c6' => black_king,
                                              'd3' => nil,
                                              'd4' => nil,
                                              'e1' => white_king,
                                              'e2' => white_rook,
                                              'e3' => nil,
                                              'e4' => black_rook })
        board = game.instance_variable_get(:@board)
        result = game.valid_rook_move?(black_rook, destination, board)
        expect(result).to eq(false)
      end
    end
  end

  describe '#valid_knight_move?' do
    context 'moves one step up and two to the right and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'e7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e7' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step up and two to the right and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'e7', color: 'black')
        destination = 'e7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e7' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step up and two to the left and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'c7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'c7' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step up and two to the left and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'c7', color: 'black')
        destination = 'c7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'c7' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step down and two to the right and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'f4'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'f4' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step down and two to the right and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'f4', color: 'black')
        destination = 'f4'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'f4' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step down and two to the left and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'b4'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'b4' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves one step down and two to the left and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'b4', color: 'black')
        destination = 'b4'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'b4' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps up and one to the right and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'e7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e7' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps up and one to the right destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'e7', color: 'black')
        destination = 'e7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e7' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps up and one to the left and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'c7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'c7' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps up and one to the left and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'c7', color: 'black')
        destination = 'c7'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'c7' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps down and one to the right and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'e3'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e3' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps down and one to the right and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'e3', color: 'black')
        destination = 'e3'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'e3' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps down and one to the left and destination is empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5')
        destination = 'c3'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'c3' => nil })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves two steps down and one to the left and destination has an opponent piece' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd5', color: 'white')
        piece2 = instance_double(Piece, position: 'c3', color: 'black')
        destination = 'c3'
        game.instance_variable_set(:@board, { 'd5' => piece,
                                              'c3' => piece2 })
        result = game.valid_knight_move?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_bishop_move' do
    context 'moves on upward diagonal (up and right or down and left) and destination
     is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4')
        destination = 'a1'
        game.instance_variable_set(:@board, { 'a1' => nil,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => piece })
        result = game.valid_bishop_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves on upward diagonal (up and right or down and left) and destination
     has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4', color: 'white')
        piece2 = instance_double(Piece, position: 'a1', color: 'black')
        destination = 'a1'
        game.instance_variable_set(:@board, { 'a1' => piece2,
                                              'b2' => nil,
                                              'c3' => nil,
                                              'd4' => piece })
        result = game.valid_bishop_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves downward diagonal (up and left or down and right) and destination
     is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4')
        destination = 'a7'
        game.instance_variable_set(:@board, { 'a7' => nil,
                                              'b6' => nil,
                                              'c5' => nil,
                                              'd4' => piece })
        result = game.valid_bishop_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves on downward diagonal (up and left or down and right) and destination
     has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4', color: 'white')
        piece2 = instance_double(Piece, position: 'a7', color: 'black')
        destination = 'a7'
        game.instance_variable_set(:@board, { 'a7' => piece2,
                                              'b6' => nil,
                                              'c5' => nil,
                                              'd4' => piece })
        result = game.valid_bishop_move?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_queen_move?' do
    context 'moves horizontally and destination is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4')
        destination = 'h4'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'e4' => nil,
                                              'f4' => nil,
                                              'g4' => nil,
                                              'h4' => nil })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves horizontally and destination has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4', color: 'white')
        piece2 = instance_double(Piece, position: 'h4', color: 'black')
        destination = 'h4'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'e4' => nil,
                                              'f4' => nil,
                                              'g4' => nil,
                                              'h4' => piece2 })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves vertically and destination is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4')
        destination = 'd8'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'd5' => nil,
                                              'd6' => nil,
                                              'd7' => nil,
                                              'd8' => nil })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves vertically and destination has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4', color: 'white')
        piece2 = instance_double(Piece, position: 'd8', color: 'black')
        destination = 'd8'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'd5' => nil,
                                              'd6' => nil,
                                              'd7' => nil,
                                              'd8' => piece2 })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves on upward diagonal and destination is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4')
        destination = 'h8'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'e5' => nil,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => nil })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves on upward diagonal and destination has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4', color: 'white')
        piece2 = instance_double(Piece, position: 'h8', color: 'black')
        destination = 'h8'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'e5' => nil,
                                              'f6' => nil,
                                              'g7' => nil,
                                              'h8' => piece2 })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves on downward diagonal and destination is empty and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4')
        destination = 'a7'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'c5' => nil,
                                              'b6' => nil,
                                              'a7' => nil })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'moves on downward diagonal and destination has an opponent piece and squares inbetween are empty' do
      it 'returns true' do
        piece = instance_double(Piece, position: 'd4', color: 'white')
        piece2 = instance_double(Piece, position: 'a7', color: 'black')
        destination = 'a7'
        game.instance_variable_set(:@board, { 'd4' => piece,
                                              'c5' => nil,
                                              'b6' => nil,
                                              'a7' => piece2 })
        result = game.valid_queen_move?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_king_move?' do
    context 'when king moves 1 step up and 1 step left' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'c5'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step up' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'd5'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step up and 1 step right' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'e5'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step right' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'e4'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step down and 1 step right' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'e3'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step down' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'd3'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step down and 1 step left' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'c3'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king moves 1 step left' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'king', position: 'd4', color: 'white')
        destination = 'c4'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when king move valid_castling is true' do
      it 'returns true' do
        allow(game).to receive(:valid_castling?).and_return(true)
        piece = instance_double(Piece, type: 'king', position: 'e1', color: 'white')
        destination = 'g1'
        result = game.valid_king_move?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_en_passant?' do
    context 'when piece is a white pawn moving one square to upper right diagonal
             and last move was a black pawn moving from two squares up and one right
             to zero up and one right' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'f5')
        destination = 'g6'
        last_move = instance_double(Move, type: 'pawn', color: 'black',
                                          origin: 'g7', destination: 'g5')
        game.instance_variable_set(:@moves, [last_move])
        result = game.valid_en_passant?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece is a white pawn moving one square to upper left diagonal
             and last move was a black pawn moving from two squares up and one left
             to zero up and one left' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'white', position: 'f5')
        destination = 'e6'
        last_move = instance_double(Move, type: 'pawn', color: 'black',
                                          origin: 'e7', destination: 'e5')
        game.instance_variable_set(:@moves, [last_move])
        result = game.valid_en_passant?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece is a black pawn moving one square to lower right diagonal
             and last move was a white pawn moving from two squares down and one right
             to zero down and one right' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'black', position: 'd4')
        destination = 'e3'
        last_move = instance_double(Move, type: 'pawn', color: 'white',
                                          origin: 'e2', destination: 'e4')
        game.instance_variable_set(:@moves, [last_move])
        result = game.valid_en_passant?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when piece is a black pawn moving one square to lower left diagonal
             and last move was a white pawn moving from two squares down and one left
             to zero down and one left' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'black', position: 'b4')
        destination = 'a3'
        last_move = instance_double(Move, type: 'pawn', color: 'white',
                                          origin: 'a2', destination: 'a4')
        game.instance_variable_set(:@moves, [last_move])
        result = game.valid_en_passant?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_castling?' do
    context 'white king right rook' do
      let(:king) do
        instance_double(Piece, type: 'king', color: 'white', position: 'e1',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:rook) do
        instance_double(Piece, type: 'rook', color: 'white', position: 'h1',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:destination) { 'g1' }

      context 'when all conditions are valid' do
        it 'returns true' do
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'f1' => nil,
                                                'g1' => nil,
                                                'h1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(true)
        end
      end

      context 'when the king has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'king', color: 'white', origin: 'e1', destination: 'e2')
          move2 = instance_double(Move, type: 'king', color: 'white', origin: 'e2', destination: 'e1')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the rook has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'rook', color: 'white', origin: 'h1', destination: 'h2')
          move2 = instance_double(Move, type: 'rook', color: 'white', origin: 'h2', destination: 'h1')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when there are pieces between the king and the rook' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'white', position: 'f1',
                                          :position= => nil, active: true)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'f1' => bishop,
                                                'g1' => nil,
                                                'h1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king is in check' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'black', position: 'g3',
                                          :position= => nil, active: true, :active= => nil)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'g3' => bishop,
                                                'h1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king passes through a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'white', 'e1', true)
          rook = Piece.new('rook', 'white', 'h1', true)
          bishop = Piece.new('bishop', 'black', 'd3', true)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'd3' => bishop,
                                                'h1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king lands on a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'white', 'e1', true)
          rook = Piece.new('rook', 'white', 'h1', true)
          bishop = Piece.new('bishop', 'black', 'e3', true)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'e3' => bishop,
                                                'h1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end
    end

    context 'white king left rook' do
      let(:king) do
        instance_double(Piece, type: 'king', color: 'white', position: 'e1',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:rook) do
        instance_double(Piece, type: 'rook', color: 'white', position: 'a1',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:destination) { 'c1' }

      context 'when all conditions are valid' do
        it 'returns true' do
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'd1' => nil,
                                                'c1' => nil,
                                                'b1' => nil,
                                                'a1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(true)
        end
      end

      context 'when the king has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'king', color: 'white', origin: 'e1', destination: 'e2')
          move2 = instance_double(Move, type: 'king', color: 'white', origin: 'e2', destination: 'e1')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the rook has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'rook', color: 'white', origin: 'a1', destination: 'a2')
          move2 = instance_double(Move, type: 'rook', color: 'white', origin: 'a2', destination: 'a1')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when there are pieces between the king and the rook' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'white', position: 'b1',
                                          :position= => nil, active: true)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'b1' => bishop,
                                                'g1' => nil,
                                                'a1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king is in check' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'black', position: 'g3',
                                          :position= => nil, active: true, :active= => nil)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'g3' => bishop,
                                                'a1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king passes through a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'white', 'e1', true)
          rook = Piece.new('rook', 'white', 'a1', true)
          bishop = Piece.new('bishop', 'black', 'f3', true)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'f3' => bishop,
                                                'a1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king lands on a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'white', 'e1', true)
          rook = Piece.new('rook', 'white', 'a1', true)
          bishop = Piece.new('bishop', 'black', 'e3', true)
          game.instance_variable_set(:@board, { 'e1' => king,
                                                'e3' => bishop,
                                                'a1' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end
    end

    context 'black king right rook' do
      let(:king) do
        instance_double(Piece, type: 'king', color: 'black', position: 'e8',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:rook) do
        instance_double(Piece, type: 'rook', color: 'black', position: 'h8',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:destination) { 'g8' }

      context 'when all conditions are valid' do
        it 'returns true' do
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'f8' => nil,
                                                'g8' => nil,
                                                'h8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(true)
        end
      end

      context 'when the king has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'king', color: 'black', origin: 'e8', destination: 'e7')
          move2 = instance_double(Move, type: 'king', color: 'black', origin: 'e7', destination: 'e8')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the rook has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'rook', color: 'black', origin: 'h8', destination: 'h7')
          move2 = instance_double(Move, type: 'rook', color: 'black', origin: 'h7', destination: 'h8')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when there are pieces between the king and the rook' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'black', position: 'f8',
                                          :position= => nil, active: true)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'f8' => bishop,
                                                'g8' => nil,
                                                'h8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king is in check' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'white', position: 'g6',
                                          :position= => nil, active: true, :active= => nil)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'g6' => bishop,
                                                'h8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king passes through a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'black', 'e8', true)
          rook = Piece.new('rook', 'black', 'h8', true)
          bishop = Piece.new('bishop', 'white', 'd6', true)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'd6' => bishop,
                                                'h8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king lands on a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'black', 'e8', true)
          rook = Piece.new('rook', 'black', 'h8', true)
          bishop = Piece.new('bishop', 'white', 'e6', true)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'e6' => bishop,
                                                'h8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end
    end

    context 'black king left rook' do
      let(:king) do
        instance_double(Piece, type: 'king', color: 'black', position: 'e8',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:rook) do
        instance_double(Piece, type: 'rook', color: 'black', position: 'a8',
                               :position= => nil, active: true, :active= => nil)
      end
      let(:destination) { 'c8' }

      context 'when all conditions are valid' do
        it 'returns true' do
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'd8' => nil,
                                                'c8' => nil,
                                                'b8' => nil,
                                                'a8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(true)
        end
      end

      context 'when the king has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'king', color: 'black', origin: 'e8', destination: 'e7')
          move2 = instance_double(Move, type: 'king', color: 'black', origin: 'e7', destination: 'e8')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the rook has previously moved during the game' do
        it 'returns false' do
          move1 = instance_double(Move, type: 'rook', color: 'black', origin: 'a8', destination: 'a7')
          move2 = instance_double(Move, type: 'rook', color: 'black', origin: 'a7', destination: 'a8')
          game.instance_variable_set(:@moves, [move1, move2])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when there are pieces between the king and the rook' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'black', position: 'b8',
                                          :position= => nil, active: true)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'b8' => bishop,
                                                'g8' => nil,
                                                'a8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king is in check' do
        it 'returns false' do
          bishop = instance_double(Piece, type: 'bishop', color: 'white', position: 'g6',
                                          :position= => nil, active: true, :active= => nil)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'g6' => bishop,
                                                'a8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king passes through a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'black', 'e8', true)
          rook = Piece.new('rook', 'black', 'a8', true)
          bishop = Piece.new('bishop', 'white', 'f6', true)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'f6' => bishop,
                                                'a8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end

      context 'when the king lands on a square attacked by an enemy piece - REAL OBJECTS' do
        it 'returns false' do
          king = Piece.new('king', 'black', 'e8', true)
          rook = Piece.new('rook', 'black', 'a8', true)
          bishop = Piece.new('bishop', 'white', 'e6', true)
          game.instance_variable_set(:@board, { 'e8' => king,
                                                'e6' => bishop,
                                                'a8' => rook })
          game.instance_variable_set(:@moves, [])
          result = game.valid_castling?(king, destination)
          expect(result).to eq(false)
        end
      end
    end
  end

  describe '#clone_board' do
    context 'when called' do
      it 'returns a clone of board with cloned pieces' do
        rook = instance_double(Piece, type: 'rook', color: 'white')
        pawn = instance_double(Piece, type: 'pawn', color: 'black')
        game.instance_variable_set(:@board, { 'a1' => rook,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => pawn })
        board = game.instance_variable_get(:@board)
        new_board = game.clone_board(board)

        # board and new_board should not be the same object
        expect(new_board).not_to eq(board)

        # board should not suffer changes on its pieces
        expect(board['a1']).to eq(rook)
        expect(board['a4']).to eq(nil)
        expect(board['a5']).to eq(pawn)

        # new_board's rook and board's rook should have the same properties but
        # should not be the same object
        expect(new_board['a1'].type).to eq('rook')
        expect(new_board['a1'].color).to eq('white')
        expect(new_board['a1']).not_to eq(board['a1'])

        # new_board's pawn and board's pawn should have the same properties but
        # should not be the same object
        expect(new_board['a5'].type).to eq('pawn')
        expect(new_board['a5'].color).to eq('black')
        expect(new_board['a5']).not_to eq(board['a5'])
      end
    end
  end

  describe '#implement_simple_move' do
    context 'when called and destination square is empty' do
      it 'moves piece to destination and leaves nil where piece originally was' do
        rook = instance_double(Piece, type: 'rook', position: 'a1', :position= => nil)
        destination = 'a4'
        game.instance_variable_set(:@board, { 'a1' => rook,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => nil })
        board = game.instance_variable_get(:@board)

        # rook's position property should be changed to destination
        expect(rook).to receive(:position=).with(destination)

        game.implement_simple_move(rook, destination)

        # board should have nil on rook's original position
        expect(board['a1']).to eq(nil)

        # board should have moved rook to destination
        expect(board[destination]).to eq(rook)
      end
    end

    context 'when called and destination square has another piece' do
      it 'replaces and deactivates the piece on destination, and leaves nil where piece originally was' do
        rook = instance_double(Piece, type: 'rook', color: 'white', position: 'a1', :position= => nil)
        pawn = instance_double(Piece, type: 'pawn', color: 'black', :position= => nil, :active= => nil)
        destination = 'a5'
        game.instance_variable_set(:@board, { 'a1' => rook,
                                              'a2' => nil,
                                              'a3' => nil,
                                              'a4' => nil,
                                              'a5' => pawn })
        board = game.instance_variable_get(:@board)

        # rook's position property should be changed to destination
        expect(rook).to receive(:position=).with(destination)

        # pawn's active property should be changed to false
        expect(pawn).to receive(:active=).with(false)

        game.implement_simple_move(rook, destination)

        # board should have nil on rook's original position
        expect(board['a1']).to eq(nil)

        # board should have moved rook to destination
        expect(board[destination]).to eq(rook)
      end
    end
  end

  describe '#pieces' do
    context 'when called with black as argument' do
      it 'returns an array with only black pieces that are on board' do
        piece1 = instance_double(Piece, color: 'white')
        piece2 = instance_double(Piece, color: 'white')
        piece3 = instance_double(Piece, color: 'black')
        piece4 = instance_double(Piece, color: 'black')
        piece5 = instance_double(Piece, color: 'black')
        piece6 = instance_double(Piece, color: 'black')
        game.instance_variable_set(:@board, { 'a1' => piece1,
                                              'a2' => piece2,
                                              'a3' => piece3,
                                              'a4' => piece4,
                                              'a5' => piece5,
                                              'a6' => piece6,
                                              'a7' => nil })
        board = game.instance_variable_get(:@board)
        result = game.pieces('black', board)
        model = [piece3, piece4, piece5, piece6]
        expect(result).to eq(model)
      end
    end

    context 'when called with white as argument' do
      it 'returns an array with only white pieces that are on board' do
        piece1 = instance_double(Piece, color: 'white')
        piece2 = instance_double(Piece, color: 'white')
        piece3 = instance_double(Piece, color: 'black')
        piece4 = instance_double(Piece, color: 'black')
        piece5 = instance_double(Piece, color: 'black')
        piece6 = instance_double(Piece, color: 'black')
        game.instance_variable_set(:@board, { 'a1' => piece1,
                                              'a2' => piece2,
                                              'a3' => piece3,
                                              'a4' => piece4,
                                              'a5' => piece5,
                                              'a6' => piece6,
                                              'a7' => nil })
        board = game.instance_variable_get(:@board)
        result = game.pieces('white', board)
        model = [piece1, piece2]
        expect(result).to eq(model)
      end
    end
  end

  describe '#kings_location' do
    context 'when given own as argument for king and a white piece as argument' do
      it 'returns the location of the white king' do
        piece1 = instance_double(Piece, color: 'white', type: 'rook', position: 'a1')
        piece2 = instance_double(Piece, color: 'white', type: 'bishop', position: 'a2')
        piece3 = instance_double(Piece, color: 'black', type: 'pawn', position: 'a3')
        piece4 = instance_double(Piece, color: 'black', type: 'knight', position: 'a4')
        piece5 = instance_double(Piece, color: 'black', type: 'queen', position: 'a5')
        black_king = instance_double(Piece, color: 'black', type: 'king', position: 'a6')
        white_king = instance_double(Piece, color: 'white', type: 'king', position: 'a7')
        game.instance_variable_set(:@board, { 'a1' => piece1,
                                              'a2' => piece2,
                                              'a3' => piece3,
                                              'a4' => piece4,
                                              'a5' => piece5,
                                              'a6' => black_king,
                                              'a7' => white_king,
                                              'a8' => nil })
        result = game.kings_location('white')
        kings_location = white_king.position
        expect(result).to eq(kings_location)
      end
    end

    context 'when given opponent as argument for king and a white piece as argument' do
      it 'returns the location of the black king' do
        piece1 = instance_double(Piece, color: 'white', type: 'rook', position: 'a1')
        piece2 = instance_double(Piece, color: 'white', type: 'bishop', position: 'a2')
        piece3 = instance_double(Piece, color: 'black', type: 'pawn', position: 'a3')
        piece4 = instance_double(Piece, color: 'black', type: 'knight', position: 'a4')
        piece5 = instance_double(Piece, color: 'black', type: 'queen', position: 'a5')
        black_king = instance_double(Piece, color: 'black', type: 'king', position: 'a6')
        white_king = instance_double(Piece, color: 'white', type: 'king', position: 'a7')
        game.instance_variable_set(:@board, { 'a1' => piece1,
                                              'a2' => piece2,
                                              'a3' => piece3,
                                              'a4' => piece4,
                                              'a5' => piece5,
                                              'a6' => black_king,
                                              'a7' => white_king,
                                              'a8' => nil })
        result = game.kings_location('black')
        kings_location = black_king.position
        expect(result).to eq(kings_location)
      end
    end

    context 'when given own as argument for king and a black piece as argument' do
      it 'returns the location of the black king' do
        piece1 = instance_double(Piece, color: 'white', type: 'rook', position: 'a1')
        piece2 = instance_double(Piece, color: 'white', type: 'bishop', position: 'a2')
        piece3 = instance_double(Piece, color: 'black', type: 'pawn', position: 'a3')
        piece4 = instance_double(Piece, color: 'black', type: 'knight', position: 'a4')
        piece5 = instance_double(Piece, color: 'black', type: 'queen', position: 'a5')
        black_king = instance_double(Piece, color: 'black', type: 'king', position: 'a6')
        white_king = instance_double(Piece, color: 'white', type: 'king', position: 'a7')
        game.instance_variable_set(:@board, { 'a1' => piece1,
                                              'a2' => piece2,
                                              'a3' => piece3,
                                              'a4' => piece4,
                                              'a5' => piece5,
                                              'a6' => black_king,
                                              'a7' => white_king,
                                              'a8' => nil })
        result = game.kings_location('black')
        kings_location = black_king.position
        expect(result).to eq(kings_location)
      end
    end

    context 'when given opponent as argument for king and a black piece as argument' do
      it 'returns the location of the white king' do
        piece1 = instance_double(Piece, color: 'white', type: 'rook', position: 'a1')
        piece2 = instance_double(Piece, color: 'white', type: 'bishop', position: 'a2')
        piece3 = instance_double(Piece, color: 'black', type: 'pawn', position: 'a3')
        piece4 = instance_double(Piece, color: 'black', type: 'knight', position: 'a4')
        piece5 = instance_double(Piece, color: 'black', type: 'queen', position: 'a5')
        black_king = instance_double(Piece, color: 'black', type: 'king', position: 'a6')
        white_king = instance_double(Piece, color: 'white', type: 'king', position: 'a7')
        game.instance_variable_set(:@board, { 'a1' => piece1,
                                              'a2' => piece2,
                                              'a3' => piece3,
                                              'a4' => piece4,
                                              'a5' => piece5,
                                              'a6' => black_king,
                                              'a7' => white_king,
                                              'a8' => nil })
        result = game.kings_location('white')
        kings_location = white_king.position
        expect(result).to eq(kings_location)
      end
    end
  end

  describe '#king_in_check?' do
    context 'when using own as argument and moving piece to a position that
             puts own king in check but does not put opponent king in check' do
      it 'returns true' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1',
                                            :position= => nil, :active= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'd3',
                                            :position= => nil, :active= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e7',
                                            :position= => nil, :active= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6',
                                            :position= => nil, :active= => nil)
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd3' => white_rook })
        result = game.king_in_check?('white')
        expect(result).to eq(true)
      end
    end

    context 'when using own as argument and moving piece to a position that
             does not put own king in check but puts opponent king in check' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1',
                                            :position= => nil, :active= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'e6',
                                            :position= => nil, :active= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e7',
                                            :position= => nil, :active= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6',
                                            :position= => nil, :active= => nil)
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => white_rook,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd3' => nil })
        result = game.king_in_check?('white')
        expect(result).to eq(false)
      end
    end

    context 'when using opponent as argument and moving piece to a position that
             puts own king in check but does not put opponent king in check' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'e1',
                                            :position= => nil, :active= => nil)
        white_rook = instance_double(Piece, type: 'rook', color: 'white', position: 'd3',
                                            :position= => nil, :active= => nil)
        black_rook = instance_double(Piece, type: 'rook', color: 'black', position: 'e7',
                                            :position= => nil, :active= => nil)
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'c6',
                                            :position= => nil, :active= => nil)
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd3' => white_rook })
        result = game.king_in_check?('black')
        expect(result).to eq(false)
      end
    end

    context 'when using opponent as argument and moving piece to a position that
             does not put own king in check but puts opponent king in check - REAL OBJECTS' do
      it 'returns true' do
        white_king = Piece.new('king', 'white', 'e1', true)
        white_rook = Piece.new('rook', 'white', 'e6', true)
        black_rook = Piece.new('rook', 'black', 'e7', true)
        black_king = Piece.new('king', 'black', 'c6', true)
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => white_rook,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd3' => nil,
                                              'd6' => nil })
        result = game.king_in_check?('black')
        expect(result).to eq(true)
      end
    end

    context 'when using own as argument and moving own king to a position that
             puts own king in check but does not put opponent king in check - REAL OBJECTS' do
      it 'returns true' do
        white_king = Piece.new('king', 'white', 'e1', true)
        black_rook = Piece.new('rook', 'black', 'e7', true)
        black_king = Piece.new('king', 'black', 'c6', true)
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd1' => nil,
                                              'd3' => nil,
                                              'd6' => nil })
        result = game.king_in_check?('white')
        expect(result).to eq(true)
      end
    end

    context 'when using own as argument and moving own king to a position that
             does not put own king in check but puts opponent king in check - REAL OBJECTS' do
      it 'returns false' do
        white_king = Piece.new('king', 'white', 'd2', true)
        white_rook = Piece.new('rook', 'white', 'c1', true)
        black_rook = Piece.new('rook', 'black', 'e7', true)
        black_king = Piece.new('king', 'black', 'c6', true)
        game.instance_variable_set(:@board, { 'e1' => nil,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => black_rook,
                                              'c1' => white_rook,
                                              'c2' => nil,
                                              'c6' => black_king,
                                              'd1' => nil,
                                              'd2' => white_king,
                                              'd3' => nil,
                                              'd6' => nil })
        result = game.king_in_check?('white')
        expect(result).to eq(false)
      end
    end

    context 'when using opponent as argument and moving own king to a position that
             puts own king in check but does not put opponent king in check - REAL OBJECTS' do
      it 'returns false' do
        white_king = Piece.new('king', 'white', 'e1', true)
        black_rook = Piece.new('rook', 'black', 'e7', true)
        black_king = Piece.new('king', 'black', 'c6', true)
        game.instance_variable_set(:@board, { 'e1' => white_king,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => black_rook,
                                              'c6' => black_king,
                                              'd1' => nil,
                                              'd3' => nil,
                                              'd6' => nil })
        result = game.king_in_check?('black')
        expect(result).to eq(false)
      end
    end

    context 'when using opponent as argument and moving own king to a position that
             does not put own king in check but puts opponent king in check - REAL OBJECTS' do
      it 'returns true' do
        white_king = Piece.new('king', 'white', 'd2', true)
        white_rook = Piece.new('rook', 'white', 'c1', true)
        black_rook = Piece.new('rook', 'black', 'e7', true)
        black_king = Piece.new('king', 'black', 'c6', true)
        game.instance_variable_set(:@board, { 'e1' => nil,
                                              'e2' => nil,
                                              'e3' => nil,
                                              'e4' => nil,
                                              'e5' => nil,
                                              'e6' => nil,
                                              'e7' => black_rook,
                                              'c1' => white_rook,
                                              'c2' => nil,
                                              'c6' => black_king,
                                              'd1' => nil,
                                              'd2' => white_king,
                                              'd3' => nil,
                                              'd6' => nil })
        result = game.king_in_check?('black')
        expect(result).to eq(true)
      end
    end

    context 'when board has the following configuration and king tries to move to f1 - REAL OBJECTS' do
      it 'returns true' do
        king = Piece.new('king', 'white', 'f1', true)
        rook = Piece.new('rook', 'white', 'h1', true)
        bishop = Piece.new('bishop', 'black', 'd3', true)
        game.instance_variable_set(:@board, { 'f1' => king,
                                              'd3' => bishop,
                                              'h1' => rook })
        game.instance_variable_set(:@moves, [])
        result = game.king_in_check?('white')
        expect(result).to eq(true)
      end
    end

    context 'when board has the following configuration and king tries to move to g1 - REAL OBJECTS' do
      it 'returns true' do
        king = Piece.new('king', 'white', 'g1', true)
        rook = Piece.new('rook', 'white', 'h1', true)
        bishop = Piece.new('bishop', 'black', 'e3', true)
        game.instance_variable_set(:@board, { 'g1' => king,
                                              'e3' => bishop,
                                              'h1' => rook })
        game.instance_variable_set(:@moves, [])
        result = game.king_in_check?('white')
        expect(result).to eq(true)
      end
    end
  end

  describe '#implement_move' do
    let(:board) { game.instance_variable_get(:@board) }

    context 'when piece is pawn && valid_en_passant is true' do
      let(:piece) { instance_double(Piece, type: 'pawn') }
      let(:destination) { 'a3' }

      before do
        allow(game).to receive(:valid_en_passant?).and_return(true)
      end

      it 'receives implement_en_passant and register_move' do
        expect(game).to receive(:implement_en_passant).with(piece, destination, board)
        expect(game).to receive(:register_move).with(piece, destination)
        game.implement_move(piece, destination, board)
      end
    end

    context 'when piece is king && valid_castling is true' do
      let(:piece) { instance_double(Piece, type: 'king') }
      let(:destination) { 'a3' }

      before do
        allow(game).to receive(:valid_castling?).and_return(true)
      end

      it 'receives implement_castling and register_castling' do
        expect(game).to receive(:implement_castling).with(piece, destination, board)
        expect(game).to receive(:register_castling).with(destination)
        game.implement_move(piece, destination, board)
      end
    end

    context 'when piece is not pawn nor king' do
      let(:piece) { instance_double(Piece, type: 'queen') }
      let(:destination) { 'a3' }

      before do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        allow(game).to receive(:valid_castling?).and_return(false)
      end

      it 'receives implement_simple_move and register_move' do
        expect(game).to receive(:implement_simple_move).with(piece, destination, board)
        expect(game).to receive(:register_move).with(piece, destination)
        game.implement_move(piece, destination, board)
      end
    end

    context 'when piece is pawn and valid_en_passant is false' do
      let(:piece) { instance_double(Piece, color: 'white', type: 'pawn') }
      let(:destination) { 'a3' }

      before do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        allow(game).to receive(:valid_castling?).and_return(false)
      end

      it 'receives implement_simple_move and register_move' do
        expect(game).to receive(:implement_simple_move).with(piece, destination, board)
        expect(game).to receive(:register_move).with(piece, destination)
        game.implement_move(piece, destination, board)
      end
    end

    context 'when piece is king and valid_castling is false' do
      let(:piece) { instance_double(Piece, type: 'king') }
      let(:destination) { 'a3' }

      before do
        allow(game).to receive(:valid_en_passant?).and_return(false)
        allow(game).to receive(:valid_castling?).and_return(false)
      end

      it 'receives implement_simple_move and register_move' do
        expect(game).to receive(:implement_simple_move).with(piece, destination, board)
        expect(game).to receive(:register_move).with(piece, destination)
        game.implement_move(piece, destination, board)
      end
    end
  end

  describe '#implement_en_passant' do
    context 'when attacking pawn is white and killed pawn is to the right - REAL OBJECTS' do
      it 'deactivates killed pawn and moves attacking pawn to upper right square' do
        origin = 'c5'
        attacked_square = 'd5'
        destination = 'd6'
        attacking_pawn = Piece.new('pawn', 'white', origin, true)
        killed_pawn = Piece.new('pawn', 'black', attacked_square, true)
        game.instance_variable_set(:@board, { origin => attacking_pawn,
                                              attacked_square => killed_pawn,
                                              destination => nil })
        board = game.instance_variable_get(:@board)
        game.implement_en_passant(attacking_pawn, destination)
        expect(killed_pawn.active).to eq(false)
        expect(killed_pawn.position).to eq(nil)
        expect(board[attacked_square]).to eq(nil)
        expect(board[destination]).to eq(attacking_pawn)
        expect(board[origin]).to eq(nil)
        expect(attacking_pawn.position).to eq(destination)
      end
    end

    context 'when attacking pawn is white and killed pawn is to the left - REAL OBJECTS' do
      it 'deactivates killed pawn and moves attacking pawn to upper left square' do
        origin = 'c5'
        attacked_square = 'b5'
        destination = 'b6'
        attacking_pawn = Piece.new('pawn', 'white', origin, true)
        killed_pawn = Piece.new('pawn', 'black', attacked_square, true)
        game.instance_variable_set(:@board, { origin => attacking_pawn,
                                              attacked_square => killed_pawn,
                                              destination => nil })
        board = game.instance_variable_get(:@board)
        game.implement_en_passant(attacking_pawn, destination)
        expect(killed_pawn.active).to eq(false)
        expect(killed_pawn.position).to eq(nil)
        expect(board[attacked_square]).to eq(nil)
        expect(board[destination]).to eq(attacking_pawn)
        expect(board[origin]).to eq(nil)
        expect(attacking_pawn.position).to eq(destination)
      end
    end

    context 'when attacking pawn is black and killed pawn is to the right - REAL OBJECTS' do
      it 'deactivates killed pawn and moves attacking pawn to lower right square' do
        origin = 'c4'
        attacked_square = 'd4'
        destination = 'd3'
        attacking_pawn = Piece.new('pawn', 'black', origin, true)
        killed_pawn = Piece.new('pawn', 'white', attacked_square, true)
        game.instance_variable_set(:@board, { origin => attacking_pawn,
                                              attacked_square => killed_pawn,
                                              destination => nil })
        board = game.instance_variable_get(:@board)
        game.implement_en_passant(attacking_pawn, destination)
        expect(killed_pawn.active).to eq(false)
        expect(killed_pawn.position).to eq(nil)
        expect(board[attacked_square]).to eq(nil)
        expect(board[destination]).to eq(attacking_pawn)
        expect(board[origin]).to eq(nil)
        expect(attacking_pawn.position).to eq(destination)
      end
    end

    context 'when attacking pawn is black and killed pawn is to the left - REAL OBJECTS' do
      it 'deactivates killed pawn and moves attacking pawn to lower left square' do
        origin = 'c4'
        attacked_square = 'b4'
        destination = 'b3'
        attacking_pawn = Piece.new('pawn', 'black', origin, true)
        killed_pawn = Piece.new('pawn', 'white', attacked_square, true)
        game.instance_variable_set(:@board, { origin => attacking_pawn,
                                              attacked_square => killed_pawn,
                                              destination => nil })
        board = game.instance_variable_get(:@board)
        game.implement_en_passant(attacking_pawn, destination)
        expect(killed_pawn.active).to eq(false)
        expect(killed_pawn.position).to eq(nil)
        expect(board[attacked_square]).to eq(nil)
        expect(board[destination]).to eq(attacking_pawn)
        expect(board[origin]).to eq(nil)
        expect(attacking_pawn.position).to eq(destination)
      end
    end
  end

  describe '#implement_castling' do
    context 'when king is white and destination is g1 - REAL OBJECTS' do
      it 'puts king 2 squares to the right and rook 2 squares to the left' do
        king_origin = 'e1'
        rook_origin = 'h1'
        king_destination = 'g1'
        rook_destination = 'f1'
        king = Piece.new('king', 'white', king_origin, true)
        rook = Piece.new('rook', 'white', rook_origin, true)
        game.instance_variable_set(:@board, { king_origin => king,
                                              rook_destination => nil,
                                              king_destination => nil,
                                              rook_origin => rook })
        board = game.instance_variable_get(:@board)
        game.implement_castling(king, king_destination)
        expect(board[king_origin]).to eq(nil)
        expect(board[rook_origin]).to eq(nil)
        expect(board[king_destination]).to eq(king)
        expect(board[rook_destination]).to eq(rook)
        expect(king.position).to eq(king_destination)
        expect(rook.position).to eq(rook_destination)
      end
    end

    context 'when king is white and destination is c1 - REAL OBJECTS' do
      it 'puts king 2 squares to the left and rook 2 squares to the right' do
        king_origin = 'e1'
        rook_origin = 'a1'
        king_destination = 'c1'
        rook_destination = 'd1'
        king = Piece.new('king', 'white', king_origin, true)
        rook = Piece.new('rook', 'white', rook_origin, true)
        game.instance_variable_set(:@board, { king_origin => king,
                                              rook_destination => nil,
                                              king_destination => nil,
                                              rook_origin => rook })
        board = game.instance_variable_get(:@board)
        game.implement_castling(king, king_destination)
        expect(board[king_origin]).to eq(nil)
        expect(board[rook_origin]).to eq(nil)
        expect(board[king_destination]).to eq(king)
        expect(board[rook_destination]).to eq(rook)
        expect(king.position).to eq(king_destination)
        expect(rook.position).to eq(rook_destination)
      end
    end

    context 'when king is black and destination is g8 - REAL OBJECTS' do
      it 'puts king 2 squares to the right and rook 2 squares to the left' do
        king_origin = 'e8'
        rook_origin = 'h8'
        king_destination = 'g8'
        rook_destination = 'f8'
        king = Piece.new('king', 'white', king_origin, true)
        rook = Piece.new('rook', 'white', rook_origin, true)
        game.instance_variable_set(:@board, { king_origin => king,
                                              rook_destination => nil,
                                              king_destination => nil,
                                              rook_origin => rook })
        board = game.instance_variable_get(:@board)
        game.implement_castling(king, king_destination)
        expect(board[king_origin]).to eq(nil)
        expect(board[rook_origin]).to eq(nil)
        expect(board[king_destination]).to eq(king)
        expect(board[rook_destination]).to eq(rook)
        expect(king.position).to eq(king_destination)
        expect(rook.position).to eq(rook_destination)
      end
    end

    context 'when king is black and destination is c8 - REAL OBJECTS' do
      it 'puts king 2 squares to the right and rook 2 squares to the left' do
        king_origin = 'e8'
        rook_origin = 'a8'
        king_destination = 'c8'
        rook_destination = 'd8'
        king = Piece.new('king', 'white', king_origin, true)
        rook = Piece.new('rook', 'white', rook_origin, true)
        game.instance_variable_set(:@board, { king_origin => king,
                                              rook_destination => nil,
                                              king_destination => nil,
                                              rook_origin => rook })
        board = game.instance_variable_get(:@board)
        game.implement_castling(king, king_destination)
        expect(board[king_origin]).to eq(nil)
        expect(board[rook_origin]).to eq(nil)
        expect(board[king_destination]).to eq(king)
        expect(board[rook_destination]).to eq(rook)
        expect(king.position).to eq(king_destination)
        expect(rook.position).to eq(rook_destination)
      end
    end
  end

  describe '#implement_simple_move' do
    context 'when destination has a piece' do
      it 'deactivates destination piece, replaces square with attacking piece and updates
          attacking piece position property' do
        origin = 'c3'
        destination = 'c4'
        piece = Piece.new('rook', 'white', origin, true)
        piece2 = Piece.new('rook', 'black', destination, true)
        game.instance_variable_set(:@board, { origin => piece,
                                              destination => piece2 })
        board = game.instance_variable_get(:@board)
        game.implement_simple_move(piece, destination)
        expect(piece2.active).to eq(false)
        expect(piece2.position).to eq(nil)
        expect(board[destination]).to eq(piece)
        expect(piece.position).to eq(destination)
        expect(board[origin]).to eq(nil)
      end
    end

    context 'when destination has no piece' do
      it 'moves piece to destination and updates position property' do
        origin = 'c3'
        destination = 'c4'
        piece = Piece.new('rook', 'white', origin, true)
        game.instance_variable_set(:@board, { origin => piece,
                                              destination => nil })
        board = game.instance_variable_get(:@board)
        game.implement_simple_move(piece, destination)
        expect(board[destination]).to eq(piece)
        expect(piece.position).to eq(destination)
        expect(board[origin]).to eq(nil)
      end
    end
  end

  describe '#register_move' do
    it 'creates a new Move instance and adds it to instance variable moves' do
      piece = instance_double(Piece, type: 'rook', color: 'white', position: 'a1')
      destination = 'a5'
      move = instance_double(Move, type: 'rook', color: 'white', origin: 'a1', destination: destination)
      allow(Move).to receive(:new).and_return(move)
      moves = game.instance_variable_get(:@moves)
      game.register_move(piece, destination)
      expect(moves[0]).to eq(move)
    end
  end

  describe '#register_castling' do
    context 'when king is white and destination is g1' do
      it 'creates 2 Move instances with king and rook movements and adds them to
          instance variable moves' do
        king_origin = 'e1'
        king_destination = 'g1'
        rook_origin = 'h1'
        rook_destination = 'f1'
        move1 = instance_double(Move, type: 'king', color: 'white', origin: king_origin, destination: king_destination)
        move2 = instance_double(Move, type: 'rook', color: 'white', origin: rook_origin, destination: rook_destination)
        allow(Move).to receive(:new).and_return(move1, move2)
        moves = game.instance_variable_get(:@moves)
        game.register_castling(king_destination)
        expect(moves[0]).to eq(move1)
        expect(moves[1]).to eq(move2)
      end
    end

    context 'when king is white and destination is c1' do
      it 'creates 2 Move instances with king and rook movements and adds them to
          instance variable moves' do
        king_origin = 'e1'
        king_destination = 'c1'
        rook_origin = 'a1'
        rook_destination = 'd1'
        move1 = instance_double(Move, type: 'king', color: 'white', origin: king_origin, destination: king_destination)
        move2 = instance_double(Move, type: 'rook', color: 'white', origin: rook_origin, destination: rook_destination)
        allow(Move).to receive(:new).and_return(move1, move2)
        moves = game.instance_variable_get(:@moves)
        game.register_castling(king_destination)
        expect(moves[0]).to eq(move1)
        expect(moves[1]).to eq(move2)
      end
    end

    context 'when king is black and destination is g8' do
      it 'creates 2 Move instances with king and rook movements and adds them to
          instance variable moves' do
        king_origin = 'e8'
        king_destination = 'g8'
        rook_origin = 'h8'
        rook_destination = 'f8'
        move1 = instance_double(Move, type: 'king', color: 'white', origin: king_origin, destination: king_destination)
        move2 = instance_double(Move, type: 'rook', color: 'white', origin: rook_origin, destination: rook_destination)
        allow(Move).to receive(:new).and_return(move1, move2)
        moves = game.instance_variable_get(:@moves)
        game.register_castling(king_destination)
        expect(moves[0]).to eq(move1)
        expect(moves[1]).to eq(move2)
      end
    end

    context 'when king is white and destination is c8' do
      it 'creates 2 Move instances with king and rook movements and adds them to
          instance variable moves' do
        king_origin = 'e8'
        king_destination = 'c8'
        rook_origin = 'a8'
        rook_destination = 'd8'
        move1 = instance_double(Move, type: 'king', color: 'white', origin: king_origin, destination: king_destination)
        move2 = instance_double(Move, type: 'rook', color: 'white', origin: rook_origin, destination: rook_destination)
        allow(Move).to receive(:new).and_return(move1, move2)
        moves = game.instance_variable_get(:@moves)
        game.register_castling(king_destination)
        expect(moves[0]).to eq(move1)
        expect(moves[1]).to eq(move2)
      end
    end
  end

  describe '#has_legal_move?' do
    context 'when player is white and board has the following configuration - REAL OBJECTS' do
      it 'returns false' do
        white_king = Piece.new('king', 'white', 'a8', true)
        white_pawn = Piece.new('pawn', 'white', 'a7', true)
        black_king = Piece.new('king', 'black', 'c8', true)
        game.instance_variable_set(:@board, { 'a6' => nil,
                                              'a7' => white_pawn,
                                              'a8' => white_king,
                                              'b6' => nil,
                                              'b7' => nil,
                                              'b8' => nil,
                                              'c6' => nil,
                                              'c7' => nil,
                                              'c8' => black_king })
        result = game.has_legal_move?('white')
        expect(result).to eq(false)
      end
    end

    context 'when player is black and board has the following configuration - REAL OBJECTS' do
      it 'returns true' do
        white_king = Piece.new('king', 'white', 'a8', true)
        white_pawn = Piece.new('pawn', 'white', 'a7', true)
        black_king = Piece.new('king', 'black', 'c8', true)
        game.instance_variable_set(:@board, { 'a6' => nil,
                                              'a7' => white_pawn,
                                              'a8' => white_king,
                                              'b6' => nil,
                                              'b7' => nil,
                                              'b8' => nil,
                                              'c6' => nil,
                                              'c7' => nil,
                                              'c8' => black_king })
        result = game.has_legal_move?('black')
        expect(result).to eq(true)
      end
    end

    context 'when player is white and board has the following configuration - REAL OBJECTS' do
      it 'returns false' do
        white_king = Piece.new('king', 'white', 'a1', true)
        black_king = Piece.new('king', 'black', 'a3', true)
        black_bishop = Piece.new('bishop', 'black', 'd3', true)
        game.instance_variable_set(:@board, { 'a1' => white_king,
                                              'a2' => nil,
                                              'a3' => black_king,
                                              'b1' => nil,
                                              'b2' => nil,
                                              'b3' => nil,
                                              'c1' => nil,
                                              'c2' => nil,
                                              'c3' => nil,
                                              'd1' => nil,
                                              'd2' => nil,
                                              'd3' => black_bishop })
        result = game.has_legal_move?('white')
        expect(result).to eq(false)
      end
    end

    context 'when player is black and board has the following configuration - REAL OBJECTS' do
      it 'returns true' do
        white_king = Piece.new('king', 'white', 'a1', true)
        black_king = Piece.new('king', 'black', 'a3', true)
        black_bishop = Piece.new('bishop', 'black', 'd3', true)
        game.instance_variable_set(:@board, { 'a1' => white_king,
                                              'a2' => nil,
                                              'a3' => black_king,
                                              'b1' => nil,
                                              'b2' => nil,
                                              'b3' => nil,
                                              'c1' => nil,
                                              'c2' => nil,
                                              'c3' => nil,
                                              'd1' => nil,
                                              'd2' => nil,
                                              'd3' => black_bishop })
        result = game.has_legal_move?('black')
        expect(result).to eq(true)
      end
    end
  end

  describe '#only_kings' do
    context 'when there is at least one piece that is not a king' do
      it 'returns false' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'a1')
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'a3')
        black_bishop = instance_double(Piece, type: 'bishop', color: 'black', position: 'd3')
        game.instance_variable_set(:@board, { 'a1' => white_king,
                                              'a2' => nil,
                                              'a3' => black_king,
                                              'd1' => nil,
                                              'd2' => nil,
                                              'd3' => black_bishop })
        result = game.only_kings?
        expect(result).to eq(false)
      end
    end

    context 'when all pieces are kings' do
      it 'returns true' do
        white_king = instance_double(Piece, type: 'king', color: 'white', position: 'a1')
        black_king = instance_double(Piece, type: 'king', color: 'black', position: 'a3')
        game.instance_variable_set(:@board, { 'a1' => white_king,
                                              'a2' => nil,
                                              'a3' => black_king,
                                              'd1' => nil,
                                              'd2' => nil,
                                              'd3' => nil })
        result = game.only_kings?
        expect(result).to eq(true)
      end
    end
  end

  describe '#valid_promotion?' do
    context 'when a white pawn reaches line 8' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'white')
        destination = 'a8'
        result = game.valid_promotion?(piece, destination)
        expect(result).to eq(true)
      end
    end

    context 'when a black pawn reaches line 1' do
      it 'returns true' do
        piece = instance_double(Piece, type: 'pawn', color: 'black')
        destination = 'a1'
        result = game.valid_promotion?(piece, destination)
        expect(result).to eq(true)
      end
    end
  end
end
