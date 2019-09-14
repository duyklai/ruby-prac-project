class Board
    def initialize
        @feedback = []
        @roundCounter = 1
    end

    # Method for displaying current board state
    def display_board(guess)
        # Turns roundCounter to at least 2 digits to keep spacing consistent
        round_count = "Round " + @roundCounter.to_s.rjust(2, "0")
        puts "-----------------------------------"
        puts "  Guess   |  Feeback  |   Round   |"
        puts "-----------------------------------"
        puts " #{guess[0]} #{guess[1]} #{guess[2]} #{guess[3]}  |  #{@feedback[0]} #{@feedback[1]} #{@feedback[2]} #{@feedback[3]}  |  #{round_count} |"
        puts "-----------------------------------"
        puts ""
    end

    # Method checking guess and giving feedback by comparing code and player's guess
    def give_feedback(guess, code)
        @feedback = []  # Reset the @feedback array, fresh check every run
        feedback_index = 0  # Temporary index for @feedback array

        # Two 2D array for code and guess to set flags when they have been accounted for
        code2d = []
        code.each do |code_color|
            code2d << [code_color, false]
        end

        guess2d = []
        guess.each do |guess_color|
            guess2d << [guess_color, false]
        end

        # Marking all absolute (position) matches
        guess.each_with_index do |guess_color, guess_index|
            if code.include?(guess_color) # If color guesses are correct
                code.each_with_index do |code_color, code_index|
                    if guess_index == code_index && guess_color == code_color # If position is correct and color matches for guess above
                        @feedback[feedback_index] = 'O'
                        code2d[code_index][1] = true    # Change for match made
                        guess2d[guess_index][1] = true  # Change for match made
                        feedback_index += 1
                        break
                    end
                end # End of code.each_with_index
            end # End of if code.include?(guess_color)
        end # End of guess.each_with_index

        # Marking matches left regardless of positions
        guess.each_with_index do |guess_color, guess_index|
            code.each_with_index do |code_color, code_index|
                if guess2d[guess_index][1] == false # If current guess index has not match with anything yet
                    if code2d[code_index][1] == false   # AND if current code index has not been match with anything yet
                        if guess_color == code_color    # If color matches
                            @feedback[feedback_index] = 'X'
                            code2d[code_index][1] = true    # Change for match made
                            guess2d[guess_index][1] = true  # Change for match made
                            feedback_index += 1
                        end
                    end
                end # End of guess2d[guess_index][1] == false
            end # End of if code.include?(guess_color)
        end # End of guess.each_with_index

        # While there are any leftover slots (cannot find anymore matches)
        while @feedback.length < 4
            @feedback << '-'    # Filled with blank marks (incorrect color guesses)
        end
        display_board(guess)
        @roundCounter += 1  #maybe need to move this
    end

    # Method for computer guessing easier, will raise computer win rate
    # Feedback will be based upon position, which the adjust_guess method from class Computer will be checking
    def give_comp_feedback(guess, code)
        @feedback = []  # Reset the @feedback array, fresh check every run
        feedback_index = 0  # Temporary index for @feedback array

        # Marking all absolute (position) matches
        guess.each_with_index do |guess_color, guess_index|
            code.each_with_index do |code_color, code_index|
                if guess_index == code_index && guess_color == code_color # If position is correct and color matches for guess above
                    @feedback[feedback_index] = 'O'
                elsif guess_color == code_color
                    @feedback[feedback_index] = 'X'
                else
                    @feedback[feedback_index] = '-'
                end
            end # End of code.each_with_index
            feedback_index += 1
        end # End of guess.each_with_index

        display_board(guess)
        @roundCounter += 1  #maybe need to move this
    end

    # Method for checking winning (if feedback returns all O; all matches)
    def check_status()
        if @feedback.all? {|value| value == 'O'}
            return true
        end
        return false
    end

    # Setter method for feedback
    def feedback=(feedback)
        @feedback = feedback
    end

    # Getter method for feedback array
    def feedback
        @feedback
    end

    # Getter method for roundCounter
    def round_count
        @roundCounter
    end
end

class Computer
    def initialize(role)
        @role = role
        @lastGuess = []
        @color_set = %w{R O Y G B I V}
    end

    def adjust_guess(guess, feedback)
        if @lastGuess.empty?
            @lastGuess = guess
            return guess
        else
            feedback.each_with_index do |fb, fb_index|
                if fb == 'O'
                    guess[fb_index] = @lastGuess[fb_index]
                elsif fb == 'X'
                    guess[fb_index] = @lastGuess[rand(3)]
                elsif fb == '-'
                    guess[fb_index] = @color_set[rand(@color_set.size)]
                end
            end
            return guess
        end
    end # End of method adjust_guess
end # End of class Computer

class Player
    def initialize(role)
        @role = role
        @guess = []
        @won = false
        @color_set = %w{R O Y G B I V} # String randomizer to pick secret code
        @code = (0..3).map{ @color_set.to_a[rand(@color_set.size)] }
    end

    # Start the game; passed in board object
    def play_game(board, computer)
        if @role == 'codebreaker'
            while !@won && board.round_count < 13 # While still have not won, and under 12 rounds
                puts "Please enter your guess with spaces separating each colors:"
                @guess = gets.chomp.upcase
                @guess = @guess.split(" ")
                board.give_feedback(@guess, @code)
                @won = board.check_status
            end

            # End game message
            if @won
                puts "You won! You guessed the code correctly!"
            else
                puts "You have ran out of guesses! The secret code is #{@code[0]}, #{@code[1]}, #{@code[2]}, #{@code[3]}."
            end
        elsif @role == 'codecreator'
            # Instruction text for player to create code
            puts "(R)ed (O)range (Y)ellow (G)reen (B)lue (I)ndigo (V)iolet"
            # Making sure that the user input only includes valid colors
            begin
                print "Please enter your secret code of length 4 (no spaces) from the colors above (first letter): "
                choice = gets.upcase.match(/^[ROYGBIV]{4}$/)[0]
            rescue
                puts "One or more of your colors are not an option, try again."
                puts ""
                retry # Retry until the player inputs valid option
            else
            end # End of begin clause

            @code = choice.split('')
            @guess = (0..3).map{ @color_set.to_a[rand(@color_set.size)] }
            continue = "\n" # Provide player with option to wait see computer's progression round-by-round

            while !@won && board.round_count < 13 # While still have not won, and under 12 rounds
                if continue == "\n"
                    puts "Computer will take a guess"
                    sleep 1
                    @guess = computer.adjust_guess(@guess, board.feedback)
                    board.give_comp_feedback(@guess, @code)
                    @won = board.check_status
                    print "Press enter to continue or type \"END\" to skip ahead."
                    continue = gets
                elsif continue == "END\n"
                    @guess = (0..3).map{ @color_set.to_a[rand(@color_set.size)] }
                    @guess = computer.adjust_guess(@guess, board.feedback)
                    board.give_comp_feedback(@guess, @code)
                    @won = board.check_status
                end
            end

            # End game message
            if @won
                puts "The computer was able to guess your code! Better luck next time."
            else
                puts "You won! The computer was not able to guess your code."
            end

        end # End of if/else role check
    end # End of method play_game
end # End of class Player

# Flavor text; gets name of both players
puts "                  ===================================="
puts "                         WELCOME TO MASTERMIND"
puts "                  ====================================\n\n"
puts "This is a two player guessing game (you will be playing vs an AI)."
puts "One player will be the codebreaker, trying to decipher the code in 12 turns"
puts "The other will be the codecreator, choosing the code and giving feedback on the codebreaker's guesses\n\n"

puts "The available colors (can be repeating) are:"
puts "(R)ed"
puts "(O)range"
puts "(Y)ellow"
puts "(G)reen"
puts "(B)lue"
puts "(I)ndigo"
puts "(V)iolet\n\n"

puts "Here is an example with the secret code of O B B G"
puts "-----------------------------------"
puts "  Guess   |  Feeback  |   Round   |"
puts "-----------------------------------"
puts " R O Y G  |  X O - -  |  Round 1  |"
puts "-----------------------------------"
puts ""

puts "From the example above, the guess had the correct guess of (O)range and correct position and color guess of (G)reen"

puts "\nTherefore, the feedback returns (in no particular order): "
puts "• \'X\' to indicate that the (O)range guess was the correct color but INCORRECT placement"
puts "• \'O\' to indicate that the (G)reen guess was the correct color AND correct placement"
puts "• \'-\' to indicate that both the (R)ed guess and (Y)ellow guess were NOT the correct color"
puts "\n\n"
# End of flavor text

play = false
while !play
    begin
        print "Would you like to be the codebreaker(1) or codecreator(2)? "
        choice = gets.match(/^[1-2]$/)[0]
    rescue
        puts "Not an valid option, try again."
        puts ""
        retry # Retry until the player inputs valid option
    else
    end

    #Creating new objects everytime
    if choice == "1"
        player = Player.new("codebreaker")
        computer = Computer.new("codecreator")
    elsif choice == "2"
        player = Player.new("codecreator")
        computer = Computer.new("codebreaker")
    else
        puts "Not a valid choice"
    end

    board = Board.new
    player.play_game(board, computer)

    puts "Play again? (Y/N)"
    choice = gets.chomp.downcase
    if choice == 'n'
        play = true
    end
    puts "\n\n"
end