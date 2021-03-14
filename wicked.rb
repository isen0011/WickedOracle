# frozen_string_literal: true

require "discordrb"
require "json"
require_relative "lib/wicked_game"

info = JSON.parse(File.read("./info.json"))

bot = Discordrb::Commands::CommandBot.new token: info["token"], client_id: info["client_id"], prefix: "/"

puts "This bot's invite URL is #{bot.invite_url}."
puts "Click on it to invite it to your server."

game = WickedGame.new

WickedGame::COMMANDS.each do |command|
  bot.command command do |event, *args|
    game.send(command, {args: args, event: event})
  end
end

at_exit { bot.stop }

bot.run
