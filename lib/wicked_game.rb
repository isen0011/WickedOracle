require "discordrb"
require_relative "wicked_pool"

class WickedGame
  COMMANDS = %i[roll show list clear]

  def initialize
    self.player_pools = {}
  end

  def roll(event:, args:, randomizer: Random)
    player = event.author.nickname
    player_pools[player] = WickedPool.new(dice: args, randomizer: randomizer)
    "#{event.author.nickname} rolled #{player_pools[player].roll}"
  end

  # standard:disable Lint/UnusedMethodArgument for the following, which
  # don't need the args(yet), but will still be passed the args.
  def show(event:, args:)
    player = event.author.nickname
    "#{player}'s current pool is: #{player_pools[player].dice_list}"
  end

  def list(event:, args:)
    player_pools.map { |player, pool| "#{player} rolled #{pool}" }.join("\n")
  end

  def clear(event:, args:)
    player = event.author.nickname
    player_pools.delete(player)
    "Removed #{player} from the current conflict"
  end

  # standard:enable Lint/UnusedMethodArgument

  private

  attr_accessor :player_pools
end
