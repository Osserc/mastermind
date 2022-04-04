module Validation
    RANGE = [1, 2, 3, 4, 5, 6]

    def check_code_range(code)
        code.all? { | integer | RANGE.include?(integer)}
    end

    def check_code_length(code)
        code.length == 4
    end

    def confront_codes_correct(code_to_break, code_breaker)
        correct_guesses = 0
        code_to_break_modified = Array.new(code_to_break)
        code_breaker_modified = Array.new(code_breaker)

        code_breaker_modified.each_with_index do | element, index |
            if element == code_to_break[index]
                correct_guesses += 1
                code_breaker_modified[index] = nil
                code_to_break_modified[index] = nil
            end
        end
        code_to_break_modified.compact!
        code_breaker_modified.compact!
        return correct_guesses, code_to_break_modified, code_breaker_modified
    end

    def confront_codes_partial(code_to_break_modified, code_breaker)
        partial_guesses = 0

        code_to_break_modified.each do | element |
            if code_breaker.include?(element)
                partial_guesses += 1
            end
        end
        return partial_guesses     
    end
end

class Game
    include Validation

    def play_game
        rounds = 0
        player_one = make_player_one()
        player_two = make_player_two(player_one)
        code_to_break = input_and_check_code_maker(player_one, player_two)
        while rounds < 12 do
            code_breaker = input_and_check_code_breaker(player_one, player_two)
            correct_guesses, code_to_break_modified, code_breaker_modified = confront_codes_correct(code_to_break, code_breaker)
            partial_guesses = confront_codes_partial(code_to_break_modified, code_breaker_modified)
            read_results(correct_guesses, partial_guesses, code_breaker, rounds)
            rounds += 1
            if check_winner(correct_guesses, rounds, player_one, player_two) == true
                break
            end
        end
        more_rounds?()
    end

    def input_and_check_code_maker(player_one, player_two)
        if player_one.breaker == "no"
            puts "Please enter the code you wish your opponent to break"
            code_to_break = player_one.make_code
            until check_code_range(code_to_break) == true && check_code_length(code_to_break) == true do
                input_warning
                code_to_break = player_one.make_code
            end
        else
            code_to_break = player_two.make_code
        end
        code_to_break
    end

    def input_and_check_code_breaker(player_one, player_two)
        if player_one.breaker == "yes"
            puts "Please enter the code you think the opponent selected"
            code_breaker = player_one.make_code
            until check_code_range(code_breaker) == true && check_code_length(code_breaker) == true do
                input_warning
                code_breaker = player_one.make_code
            end
        else
            # temporarily commandering the code breaker to test
            puts "Please enter the code you think the opponent selected"
            code_breaker = player_one.make_code
            until check_code_range(code_breaker) == true && check_code_length(code_breaker) == true do
                input_warning
                code_breaker = player_one.make_code
            end
            # code_breaker = player_two.make_code
            # puts code_breaker.join
        end
        code_breaker
    end

    def make_player_one
        puts "Do you want to be the codebreaker?"
        response = gets.chomp
        until response.downcase == "yes" || response.downcase == "no" do
            puts "I\'m sorry, I didn\'t catch that.\nDo you want to be the codebreaker?"
            response = gets.chomp
        end
        player_one = Player.new(response)
    end

    def make_player_two(player_one)
        if player_one.breaker == "yes"
            player_two = Player.new("no")           
       else
           player_two = Player.new("yes")
       end
    end

    def read_results(correct_guesses, partial_guesses, code_breaker, rounds)
        puts "Results for round #{rounds + 1}\nCode #{code_breaker}: " + ("[x]" * correct_guesses) + " || " + ("[o]" * partial_guesses)
    end

    def check_winner(correct_guesses, rounds, player_one, player_two)
        if player_one.breaker == "yes"
            if correct_guesses == 4
                puts "Congratulations, you broke the code!"
                return true
            elsif rounds == 12
                puts "You lost. Looks like you could not break the code..."
                return true
            end
        elsif player_one.breaker == "no"
            if correct_guesses == 4
                puts "The computer broke your code, better luck next time."
                return true
            elsif rounds == 12
                puts "Congratulations, you managed to safeguard your code from the computer!"
                return true
            end
        end
    end

    def input_warning
        puts "Invalid code. Please put in a valid number."
    end

    def more_rounds?
        puts "The game is over, would you like to play another round? Type y for yes and n for no."
        answer = gets.chomp.downcase
        until answer == "y" || answer == "n"
            puts "I\'m sorry, I didn\'t catch that. Would you like to play another round? Type y for yes and n for no."
            answer = gets.chomp.downcase
        end
        if answer == "y"
            Game.new.play_game()
        elsif answer == "n"
            exit
        end
    end

end

class Player
    attr_reader :breaker, :human
    include Validation
    @@human = 0

    def initialize(breaker, human = @@human)
        @breaker = breaker
        @human = human
        @@human += 1
    end

    def make_code()
        if self.human.even? == true
            puts "Insert your 4-numbered code."
            code = gets.chomp.split('').map { | character | character.to_i}
        else
            code = RANGE.sample(4)
        end
    end

    def guess_code(player)

    end
end

class Code
    # attr_reader :

    def initialize(code)

    end

end

Game.new.play_game