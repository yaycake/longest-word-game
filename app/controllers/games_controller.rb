
class GamesController < ApplicationController

  require "open-uri"

  def game
    @grid = gen_grid
  end

  def score
    @guess = params[:guess]
    @grid = params[:grid]
    @time = (params[:time_elapsed].to_i)/1000
    @game_results = run_game(@guess, @grid, @time)
  end

  private

  NOT_IN_GRID = {
  score: 0,
  message: "Not in the grid!"
  }

  ZERO_LETT = {
    score: 0,
    message: "Try harder, try again!"
  }

  INVALID_WORD = {
    score: 0,
    message: "Not an English word!"
  }

  INSUFF = {
    score: 0,
    message: "Correct letters, but not in sufficient numbers!"
  }

  def gen_grid
    grid_array = []
    9.times do
      grid_array << ('A'..'Z').to_a.sample
    end
    grid_array
  end

  def run_game(attempt, grid, time_elapsed)
    result = { attempt: attempt, time: time_elapsed, grid: grid}
    if validate_word(attempt, grid) == true
      result[:score] = result[:attempt].length + (10 - result[:time])
      result[:message] = "Well done!"
    else
      result[:message] = validate_word(attempt,grid)
      result[:score] = 0
    end
    result
  end

  def validate_word(attempt, grid)
    return ZERO_LETT[:message] if attempt.size.zero?
    if attempt.split('').map {|letter| grid.include? letter.upcase }.include? false
      @invalid = NOT_IN_GRID[:message]
    elsif wagon_validate?(attempt) == false
      @invalid = INVALID_WORD[:message]
    elsif validate_number?(attempt, grid) == false
      @invalid = INSUFF[:message]
    else
      true
    end
  end

  def wagon_validate?(attempt)
    url="https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_check = open(url).read
    word = JSON.parse(word_check)
    word["found"] == true
  end

  def validate_number?(attempt, grid)
    @grid_copy = grid.dup
    word_array = attempt.upcase.split('')
    word_array.each do |letter|
      if @grid_copy.include? letter
        @grid_copy.slice!(@grid_copy.index(letter))
      else
        return false
      end
    end
  end

end
