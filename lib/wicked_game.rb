require "discordrb"
require_relative "wicked_pool"

class WickedGame
  COMMANDS = %i[roll show list clear adv help]

  def initialize
    self.player_pools = {}
  end

  def roll(event:, args:, randomizer: Random)
    player = extract_player(args, event)
    roll_for_player(player: player, dice: extract_dice(args), randomizer: randomizer)
  end

  def show(event:, args:)
    player = extract_player(args, event)
    show_for_player(player: player)
  end

  # standard:disable Lint/UnusedMethodArgument for the following, which
  # don't need the args(yet), but will still be passed the args.
  def list(event:, args:)
    sorted_player_pools.map { |player, pool| "#{player} rolled #{pool}" }.join("\n")
  end

  def help(event:, args:)
    <<~HELP
      /roll [character] [dX] [dX] [dX] [A] - roll dice (for character) - if no dice given, rolls last known dice
      /show [character] - shows current dice pool for character
      /list - shows all character's current dice pools and results
      /clear [character] - clears character's current dice pool
      /adv [character] [+|-] - Adds or removes an advantage die from character's pool
      NOTE: if [character] is omitted, the current player's name will be used
    HELP
  end
  # standard:enable Lint/UnusedMethodArgument

  def clear(event:, args:)
    player = extract_player(args, event)
    clear_for_player(player: player)
  end

  def adv(event:, args:)
    player = if args.size == 1
      event.author.nickname
    else
      args[0...-1].join(" ")
    end
    "#{player}: #{player_pools[player].adjust_advantage(args.last)}"
  end

  private

  DIE_REGEX = /d\d{1,2}/

  attr_accessor :player_pools

  def extract_player(args, event)
    player = passed_player(args)
    if player == ""
      player = event.author.nickname
    end
    player
  end

  def passed_player(args)
    args.take(first_die_index(args)).join(" ")
  end

  def extract_dice(args)
    args[first_die_index(args)..]
  end

  def first_die_index(array)
    array.index { |element| DIE_REGEX.match?(element) } || array.length
  end

  def roll_for_player(player:, dice:, randomizer: Random)
    if !dice.empty?
      player_pools[player] = WickedPool.new(dice: dice, randomizer: randomizer)
    elsif !player_pools.has_key?(player)
      return "Character #{player} has no current dice pool, and no dice were provided"
    end
    "#{player} rolled #{player_pools[player].roll}"
  end

  def show_for_player(player:)
    "#{player}'s current pool is: #{player_pools[player].dice_list}"
  end

  def clear_for_player(player:)
    player_pools.delete(player)
    "Removed #{player} from the current conflict"
  end

  def sorted_player_pools
    player_pools.sort_by { |key, value| value }.reverse.to_h
  end
end
