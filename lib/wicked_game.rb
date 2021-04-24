require "discordrb"
require_relative "wicked_pool"
require_relative "wicked_conflict"

class WickedGame
  COMMANDS = %i[roll show list clear adv help clear_all start_conflict show_conflicts]

  def initialize
    self.player_pools = {}
    self.conflicts = {}
  end

  def roll(event:, args:, randomizer: Random)
    player = extract_player(args, event)
    return "Error- two matching characters: #{player.join(", ")}" unless player.length == 1
    roll_for_player(player: player.first, dice: extract_dice(args), randomizer: randomizer)
  end

  def show(event:, args:)
    player = extract_player(args, event)
    return "Error- two matching characters: #{player.join(", ")}" unless player.length == 1
    show_for_player(player: player.first)
  end

  # standard:disable Lint/UnusedMethodArgument for the following, which
  # don't need the args(yet), but will still be passed the args.
  def start_conflict(event:, args:)
    conflict = WickedConflict.new(args.join(" "))
    conflicts[conflict.name] = conflict
    "Started new conflict: #{conflict.name}"
  end

  def show_conflicts(event:, args:)
    "List of conflicts:\n#{conflicts.keys.map { |key| "- #{key}" }.join("\n")}"
  end

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
      /start_conflict [conflict name] - starts a new conflict.  A name for the conflict is required.
      /show_conflicts - shows all conflicts
      NOTE: if [character] is omitted, the current player's name will be used
    HELP
  end

  def clear_all(event:, args:)
    players = player_pools.keys
    players.each { |player| clear_for_player(player: player) }
    "Cleared all pools: #{players.join(", ")}"
  end

  # standard:enable Lint/UnusedMethodArgument

  def clear(event:, args:)
    player = extract_player(args, event)
    return "Error- two matching characters: #{player.join(", ")}" unless player.length == 1
    clear_for_player(player: player.first)
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

  attr_accessor :player_pools, :conflicts

  def extract_player(args, event)
    player = passed_player(args)
    if player == ""
      [event.author.nickname]
    else
      player_lookup(player)
    end
  end

  def passed_player(args)
    args.take(first_die_index(args)).join(" ")
  end

  def player_lookup(player)
    if player_pools.keys.find { |key| key.start_with?(player) }
      player_pools.keys.filter { |key| key.start_with?(player) }
    else
      [player]
    end
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
