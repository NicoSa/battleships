require 'eventmachine'
require 'terminal-table'

require_relative 'lib/game_loader'
require_relative 'lib/battleship_game'

class BattleShipGameServer < EventMachine::Connection
   def post_init
     @game = BattleShipGame.new
     send_data "Welcome to battleships"     
     send_data "\n"
     show_help
     send_input
     puts "-- someone connected to the echo server!"
   end

   def send_input
     send_data "\n"
     send_data "battleships: "
   end

   def board_for board
     puts board.inspect
     if @game.player.name == board.owner
       rows = board.rows
     else
       rows = board.opponent_view
     end
     table = Terminal::Table.new :title => "#{board.owner}'s board", :headings => [''] + ('A'..'J').to_a, :style => {:width => 80} do |t|
       rows.each_with_index do |row, index|
         t << [index+1].concat(row)
         t << :separator unless index == 9
       end
     end
     send_data table.to_s
   end

   def receive_data data
     if data =~  /clear/i
       send_data "\x1b[2J\x1b[1;1H"
     elsif data =~ /restart/i
       @game = BattleShipGame.new
       send_data "Started a new game, please add the players"
     elsif data =~ /list/i
       send_data @game.players
     elsif data =~ /help/i
       show_help
     elsif data =~ /quit/i
       send_data "\nThank you for playing battleships!\n\n"
       close_connection_after_writing
     elsif @game.started?
       if data =~ /restart/i
         @game = BattleShipGame.new
         send_data "Started a new game, please add the players"
       elsif data =~ /winner/i
         send_data @game.winner
       elsif @game.finished?
         send_data @game.winner
       elsif data =~ /my board/i
         board_for @game.display_board
       elsif data =~ /opponents board/i
         board_for @game.other_board
       elsif data =~ /[A-J][1-9]|10/i
         send_data @game.shoot data.chop
       else
         send_data "Please specify a shot like [A-J][1-10]"
       end
     elsif data =~ /add_player/i
       name = data.sub('add_player','').chop.squeeze
       puts name.inspect
       name = '' if name == ' '
       player = Player.new name
       send_data @game.add player
     else
       send_data "I don't understand.\n"
       show_help
     end
     send_input
   end

   def show_help
     table = Terminal::Table.new title: 'Battleships help', style: {width: 80 } do |t|
       t << ["help", "Shows the help menu for the game"]
       t << ["add_player", "Adds a player to the game"]
       t << ['list', 'Lists all the players in the game']
       t << ['my board', 'Displays the current status of your board']
       t << ['opponents board', 'Displays the current status of your opponents board']
       t << ['clear', "Clears the screen"]
       t << ['quit', 'Ends the session']
       t << ['restart', 'Restarts the game']
     end
     send_data table.to_s
   end

   def unbind
     puts "-- someone disconnected from the echo server!"
  end
end

abort("Please specify a path where the game files are!") unless ARGV.first
begin
  loader = GameLoader.new ARGV.first
  loader.load
  EventMachine.run {
    EventMachine.start_server("battleships.server", 8010, BattleShipGameServer)
  }
rescue RuntimeError => e
  puts "Could not load the game!"
  puts "Reason: #{e.message}"
  puts "Please make sure you implement the methods that are needed"
  rescue Interrupt => e
    puts "\nbye\n"
end
