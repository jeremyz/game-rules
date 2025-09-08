#! /bin/env ruby
#

class F1Exception < Exception
end

class Dice
    @rand = Random.new
    @g2 = [2,3,3,4,4,4]
    @g3 = [4,5,6,6,7,7,8,8]
    def self.g1
        @rand.rand(2) + 1
    end
    def self.g2
        @g2[@rand.rand(6)]
    end
    def self.g3
        @g3[@rand.rand(8)]
    end
    def self.g4
        @rand.rand(6) + 7
    end
    def self.g5
        @rand.rand(10) + 11
    end
    def self.g6
        @rand.rand(10) + 21
    end
    def self.black
        @rand.rand(20) + 1
    end
end

class Car
    GEAR_MIN = 1
    GEAR_MAX = 6
    attr_reader :driver, :num
    attr_reader :lap, :grid_pos, :track_cell
    attr_reader :gear, :tyres, :breaks, :fuel, :bodywork, :engine
    # suspension ?
    def initialize driver, num
        @driver = driver
        @num = num
        @lap = 1
        @grid_pos = nil
        @track_cell = nil
        @gear = 1
        @tyres = @breaks = @fuel = @engine = @bodywork = nil
    end
    def setup laps
        case laps
        when 1
            @tyres = 4
            @breaks = 3
            @fuel = 2
            @bodywork = 2
            @engine = 2
        when 2
            @tyres = 4
            @breaks = 3
            @fuel = 2
            @bodywork = 2
            @engine = 2
        else
            throw F1Exception.new "there is no setup for #{laps} laps race"
        end
    end
    def gear_up
        throw F1Exception.new "already on gear #{GEAR_MAX}" if @gear == GEAR_MAX
        @gear += 1
    end
    def gear_down
        throw F1Exception.new "already on gear #{GEAR_MIN}" if @gear == GEAR_MIN
        @gear -= 1
    end
end

