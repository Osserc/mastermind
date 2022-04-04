class Game
    
    def play_game
        player_one = make_player_one()
        player_two = make_player_two(player_one)
        puts player_one.breaker
        puts player_two.breaker
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
end

class Player
    attr_reader :breaker

    def initialize(breaker)
        @breaker = breaker
    end
end

Game.new.play_game