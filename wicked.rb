# frozen_string_literal: true
require 'discordrb'
require 'json'
require_relative 'lib/wicked_game'

info = JSON.parse(File.read('./info.json'))

bot = Discordrb::Commands::CommandBot.new token: info["token"], client_id: info["client_id"], prefix: '/'

puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

game = WickedGame.new()

bot.command :roll do |_event, *args|
  WickedPool.new(dice: args).roll.to_s
end

at_exit { bot.stop }

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
