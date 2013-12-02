class BattleShipGame
  attr_reader :player

  def initialize
    @players = {}
    @started = false
  end

  def players
    return "No one is playing at the moment" if @players.keys.empty?
    return "#{@players[@players.keys.first].name} is waiting for a challenger!" if @players.keys.length == 1
    "#{@players.values.map(&:name).join(' and')} are playing battleships."
  end

  def game_ready?
    @players.keys.length == 2
  end

  def display_board
    @player.board
  end

  def start_game
    @started = true
    @turn = 0
    message = "Ok, we are all set, let's start!\n\n"
    message << next_turn
    message
  end

  def finished?
    @players.values.reject(&:has_ships_still_floating?).any?
  end

  def winner
    return "Slow down turbo, you are still playing against #{other_board.owner}" unless finished?
    player = @players.values.select(&:has_ships_still_floating?).first
    return "Wooha, #{player.name} has won the game!" if player
    ''
  end

  def other_board
    @players.values.reject{|player| @player == player }.first.board
  end
  
  def shoot shot
    message = @player.shoot shot, other_board
    puts message
    finished?
    message << next_turn
    message
  end

  def next_turn
    @player = player_for_turn
    @turn = @turn + 1
    "#{@player.name} it is your turn! Choose your shot ([A-J][1-10])!\n"
  end

  def player_for_turn
    return @players[@players.keys.first] if @turn.odd?
    @players[@players.keys.last]
  end

  def started?
    @started
  end

  def add player
    return "Please enter the name of the player you want to add (add_player <name>)" if player.name == ''
    return "You cannot add more players to this game\n" if game_ready?
    @players[player.name]=player
    message = "Player #{player.name} added to the game\n"
    message <<  start_game if game_ready?
    message
  end
end
