# Ruby Final Project (Chess) - The Odin Project | Full-Stack Ruby on Rails Program

Repo for the Ruby Final Project of the Full-Stack Ruby on Rails Program, from [The Odin Project](https://www.theodinproject.com/).

The objective was to build a Chess Game that could be played from the CLI. The full project description and requirements can be found [here](https://www.theodinproject.com/lessons/ruby-ruby-final-project).

Features implemented:
- Initial game menu
  - Start new game
  - Load saved game
- Gameboard display after each move
  - Gameboard status with black and white chess pieces
  - Lists of lost pieces
- Gameplay
  - Moving pieces
    - Preventing invalid moves (invalid pieces, invalid moves)
    - Special moves (Castling, En passant, Promotion, Check)
  - End of game verification (Checkmate, Draw)
  - Saving game
    - Serializing to yaml
    - Saving file

## How to run the game
1. `git clone https://github.com/trebeil/TOP-chess.git`
2. `cd TOP-chess`
3. `ruby main.rb`