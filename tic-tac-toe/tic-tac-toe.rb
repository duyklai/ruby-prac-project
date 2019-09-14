class Board
    def initialize
      @board = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
      @won = false
      @turnCount = 1
      @lastPlay = []
      @winner = ""
    end

    # Method to display the current board
    def display_board
        puts "#{@board[0][0]} | #{@board[0][1]} | #{@board[0][2]}"
        puts "----------"
        puts "#{@board[1][0]} | #{@board[1][1]} | #{@board[1][2]}"
        puts "----------"
        puts "#{@board[2][0]} | #{@board[2][1]} | #{@board[2][2]}"
        puts ""
    end

    # Method to determine the current status of the game
    def check_status
        row = @lastPlay[0].to_i 
        col = @lastPlay[1].to_i
        @won = row_crossed(row) || col_crossed(col) || diagonal_crossed
    end

    # Method helper checking for rows filled
    def row_crossed(row)
        if (@board[row][0] == @board[row][1] && 
            @board[row][1] == @board[row][2] &&  
            @board[row][0] != ' ')
            return true
        end
        return false
    end # End of method row_crossed

    # Method helper checking for columns filled
    def col_crossed(col)
        if (@board[0][col] == @board[1][col] && 
            @board[1][col] == @board[2][col] &&  
            @board[0][col] != ' ')
            return true
        end
        return false
    end # End of method col_crossed

    # Method helper checking for diagonals filled
    def diagonal_crossed
        if (@board[0][0] == @board[1][1] && 
            @board[1][1] == @board[2][2] &&  
            @board[0][0] != ' ') 
            return(true); 
        elsif (@board[0][2] == @board[1][1] && 
               @board[1][1] == @board[2][0] && 
               @board[0][2] != ' ') 
            return(true); 
        end
        return false
    end # End of method diagonal_crossed

    # Method to start the game, will loop until win/lose/draw
    def play_game(player1, player2)
        while !@won && @turnCount < 10
            if @turnCount % 2 != 0 # If round is odd, player's one turn
                puts "Turn #{@turnCount}: "
                display_board
                # Check for correct input
                begin
                    print "#{player1}'s turns to play: "
                    input = gets.match(/^[0-9]$/)[0]
                rescue
                    puts "That position does not exist, try again!"
                    puts ""
                    retry # Retry until the player inputs valid position
                else
                end
                # Finding position and replacing it with the player's symbol
                @board.each_with_index do |inner_array, outer_index|
                    inner_array.each_with_index do |inner_value, inner_index|
                        if inner_value == input.to_i
                            @board[outer_index][inner_index] = 'X'
                            @lastPlay = [outer_index, inner_index]
                            @turnCount += 1 # Increment turn counter to output
                            puts "Last Play: #{@lastPlay}"
                        end
                    end
                end
                # Check status of the board
                check_status()
                if @won # If winner is found, change winner to player's name
                    @winner = player1
                end
                puts ""
            else # If round is even, player's two turn
                puts "Turn #{@turnCount}: "
                display_board
                # Check for correct input
                begin
                    print "#{player2}'s turns to play: "
                    input = gets.match(/^[0-9]$/)[0]
                rescue
                    puts "That position does not exist, try again!"
                    puts ""
                    retry # Retry until the player inputs valid position
                else
                end
                # Finding position and replacing it with the player's symbol
                @board.each_with_index do |inner_array, outer_index|
                    inner_array.each_with_index do |inner_value, inner_index|
                        if inner_value == input.to_i
                            @board[outer_index][inner_index] = 'O'
                            @lastPlay = [outer_index, inner_index]
                            @turnCount += 1 # Increment turn counter to output
                            puts "Last Play: #{@lastPlay}"
                        end
                    end
                end
                # Check status of the board
                check_status()
                if @won # If winner is found, change winner to player's name
                    @winner = player2
                end
                puts ""
            end # End of turn if-else check in method play_game
        end # End of while loop in method play_game
    end # End of method play_game

    # Method to display the final board and delcare winner
    def declare_win
        display_board
        if @winner != ""
            puts "Winner is player: #{@winner}"
        else
            puts "It is a tie!"
        end
    end
end # End of class Board

class Player
    def initialize(name, symbol)
      @name = name
      @symbol = symbol
    end

    def name
        @name
    end

    def symbol
        @symbol
    end
end

# Flavor text; gets name of both players
puts "===================================="
puts "**WELCOME TO TIC-TAC-TOE**"
puts "This is a two player game."
puts "Each turn, alternating players picks a spot (1-9) to place their symbol"
puts "First player to get 3 in a row (vertical/horizontal/diagonal) wins!"
puts "====================================\n\n"
print "Please enter player one's name: "
name = gets.chomp
player_one = Player.new(name, "X")
print "Please enter player two's name: "
name = gets.chomp
player_two = Player.new(name, "O")
puts "#{player_one.name} will be X's. #{player_two.name} will be O's."
puts "\n\n"

# Start game
play = false
while !play
    board = Board.new
    board.play_game(player_one.name, player_two.name)
    board.declare_win

    puts "Play again? (Y/N)"
    choice = gets.chomp.downcase
    if choice == 'n'
        play = true
    end
    puts "\n\n"
end