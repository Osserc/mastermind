module Validation
    RANGE = [1, 2, 3, 4, 5, 6]
    def check_code(code)
        code.all? { | integer | RANGE.include?(integer)} && code.length == 4
    end
end

class Game
    attr_reader :range
    include Validation


    def play_game
        player_one = make_player_one()
        player_two = make_player_two(player_one)
        human, computer = find_human_player(player_one, player_two)
        # now we ask what the code to guess is
        if human.breaker == "no"
            puts "Please enter the code you wish your opponent to break"
            code_to_break = human.make_code
            until check_code(code_to_break) == true do
                puts "Invalid code; please insert a valid code."
                code_to_break = human.make_code
            end
            puts code_to_break
        else
            code_to_break = computer.make_code
            puts code_to_break.join
        end
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

    def find_human_player(player_one, player_two)
        if player_one.human == 0
            return player_one, player_two
        else
            return player_two, player_one
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
        if self.human == 0
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