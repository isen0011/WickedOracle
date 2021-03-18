require "discordrb"
require_relative "wicked_pool"

class WickedGame
  COMMANDS = %i[roll show list clear roll_for show_for clear_for]

  def initialize
    self.player_pools = {}
  end

  def roll(event:, args:, randomizer: Random)
    player = event.author.nickname
    roll_for_player(player: player, dice: args, randomizer: randomizer)
  end

  # standard:disable Lint/UnusedMethodArgument for the following, which
  # don't need the args(yet), but will still be passed the args.
  def show(event:, args:)
    player = event.author.nickname
    show_for_player(player: player)
  end

  def list(event:, args:)
    player_pools.map { |player, pool| "#{player} rolled #{pool}" }.join("\n")
  end

  def clear(event:, args:)
    player = event.author.nickname
    clear_for_player(player: player)
  end

  def roll_for(event:, args:, randomizer: Random)
    player = extract_player(args)
    dice = if first_die_index(args) != 0
      extract_dice(args)
    else
      []
    end
    roll_for_player(player: player, dice: dice, randomizer: randomizer)
  end

  def show_for(event:, args:, randomizer: Random)
    show_for_player(player: extract_player(args))
  end

  def clear_for(event:, args:, randomizer: Random)
    clear_for_player(player: extract_player(args))
  end

  # standard:enable Lint/UnusedMethodArgument

  private

  DIE_REGEX = /d\d{1,2}/

  attr_accessor :player_pools

  def extract_player(args)
    args[0..first_die_index(args) - 1].join(" ")
  end

  def extract_dice(args)
    args[first_die_index(args)..]
  end

  def first_die_index(array)
    array.index { |element| DIE_REGEX.match?(element) } || 0
  end

  def roll_for_player(player:, dice:, randomizer: Random)
    if !player_pools.has_key?(player) || !dice.empty?
      player_pools[player] = WickedPool.new(dice: dice, randomizer: randomizer)
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
end
