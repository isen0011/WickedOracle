# frozen_string_literal: true

require 'discordrb'
require 'json'
require 'wickeddice'

info = JSON.parse(File.read('./info.json'))

bot = Discordrb::Commands::CommandBot.new token: info["token"], client_id: info["client_id"], prefix: '/'

bot.command :roll do |_event, *args|
  "Rolld dice"
  # "Rolled: #{args.map { |arg| WickedDice.new(arg).roll }.join(' ')}"
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
