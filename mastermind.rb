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
        correct_guesses = 0
        partial_guesses = 0
        guess_range = RANGE.repeated_permutation(4).to_a
        player_one = make_player_one()
        player_two = make_player_two(player_one)
        code_to_break = input_and_check_code_maker(player_one, player_two)
        while rounds < 12 do
            if check_human_breaker(player_one, player_two) == true
                code_breaker = input_and_check_code_breaker(player_one)
            else
                code_breaker = player_two.guess_code_computer(guess_range, rounds)
            end
            correct_guesses, code_to_break_modified, code_breaker_modified = confront_codes_correct(code_to_break, code_breaker)
            partial_guesses = confront_codes_partial(code_to_break_modified, code_breaker_modified)
            read_results(correct_guesses, partial_guesses, code_breaker, rounds, player_one)
            rounds += 1
            if check_winner(correct_guesses, rounds, player_one, player_two, code_to_break) == true
                break
            end
            guess_range = player_two.update_algorithm(correct_guesses, partial_guesses, guess_range, code_breaker)
        end
        more_rounds?()
    end

    private
    def input_and_check_code_maker(player_one, player_two)
        if player_one.breaker == "no"
            puts "Please enter the code you wish your opponent to break."
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

    def input_and_check_code_breaker(player_one)
            puts "Please enter the code you think the opponent selected."
            code_breaker = player_one.make_code
            until check_code_range(code_breaker) == true && check_code_length(code_breaker) == true do
                input_warning
                code_breaker = player_one.make_code
            end
        code_breaker
    end

    def make_player_one
        puts "Do you want to be the code-breaker? Yes or no?"
        response = gets.chomp
        until response.downcase == "yes" || response.downcase == "no" do
            puts "I\'m sorry, I didn\'t catch that.\nDo you want to be the codebreaker? Yes or no"
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

    def check_human_breaker(player_one, player_two)
        if player_one.human.even? == true && player_one.breaker == "yes"
            return true
        elsif player_two.human.even? == false && player_two.breaker == "yes"
            return false
        end
    end

    def read_results(correct_guesses, partial_guesses, code_breaker, rounds, player_one)
        puts "Results for round #{rounds + 1}\nCode #{code_breaker.join}: " + ("[x]" * correct_guesses) + " || " + ("[o]" * partial_guesses)
        if player_one.breaker == "no"
            puts "Press enter to proceed."
            gets
        end
    end

    def check_winner(correct_guesses, rounds, player_one, player_two, code_to_break)
        if player_one.breaker == "yes"
            if correct_guesses == 4
                puts "Congratulations, you broke the code!"
                return true
            elsif rounds == 12
                puts "You lost. Looks like you could not break the code...\n\nPsst, it was #{code_to_break.join}, but keep your mouth shut!\n\n"
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
        puts "Invalid code. Please put in a valid code."
    end

    def more_rounds?
        puts "The game is over, would you like to play another round? Yes or no?"
        answer = gets.chomp.downcase
        until answer == "yes" || answer == "no"
            puts "I\'m sorry, I didn\'t catch that. Would you like to play another round? Yes or no?"
            answer = gets.chomp.downcase
        end
        if answer == "yes"
            Game.new.play_game()
        elsif answer == "no"
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
            make_code_human()
        else
            code = RANGE.sample(4)
        end
    end

    def make_code_human()
        code = gets.chomp.split('').map { | character | character.to_i}
    end

    def guess_code_computer(guess_range, rounds)
        if rounds == 0
            code_breaker = [1, 1, 2, 2]
        else
            code_breaker = guess_range[0]
            return code_breaker
        end
    end

    def update_algorithm(correct_guesses, partial_guesses, guess_range, code_breaker)
        guess_range.each_with_index do | element, index |
            correct_guesses_cheat, code_to_break_modified, code_breaker_modified = confront_codes_correct(element, code_breaker)
            partial_guesses_cheat = confront_codes_partial(code_to_break_modified, code_breaker_modified)
            if correct_guesses_cheat != correct_guesses || partial_guesses_cheat != partial_guesses
                guess_range[index] = nil
            end
        end
        guess_range.compact!
        guess_range
    end

end

puts "Welcome, this is Mastermind, a game where you will prove your smarts against the computer!\nYou will either try to guess a 4-number code made by your opponent, or come up with one yourself and see whether the computer is able to guess it, depending on the role you wish to play.\nThe code-maker selects a code and the code-breaker tries to break it.\nYou will have 6 numbers at your disposal, ranging from 1 to 6, which you can arrange however you see fit. You can even choose the same digit 4 times!\nAfter every round, the code-breaker receives hints based on his performance: a [x] for each correct digit in the correct position, and a [o] for each right digit but in the wrong position.\nThe game lasts for a maximum of 12 rounds.\nAre you ready to challenge the machine overlord?\n
        P.S.: he cheats. Don\'t trust him.\n\n"
Game.new.play_game