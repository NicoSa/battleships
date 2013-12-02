class GameLoader
  def initialize path
    @path = path
  end

  def load
    print "loading game files"
    ruby_files = File.join(@path, '*.rb')
    Dir.glob(ruby_files).each do |file|
      print "."
      require file
    end
    puts " files loaded"
    check_board
    check_player
    puts "Everything OK, let's start"
  end

  def check_board
    puts "Checking the Board"
    check Board, [:owner, :register_shot, :rows, :opponent_view]
  end

  def check_player
    puts "Checking the Player"
    check Player, [:shoot, :has_ships_still_floating?]
  end

  def check clazz, methods
    methods.each do |method|
      raise "#{clazz} not implemented correctly" unless clazz.public_method_defined?(method)
    end
  end
end
