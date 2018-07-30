require 'discordrb'
require 'rest-client'
require 'json'
require 'yaml'
require 'nokogiri'
require 'open-uri'
puts 'All dependencies loaded'

CONFIG = YAML.load_file('config.yaml')
puts 'Config loaded from file'

Bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: ["<@#{CONFIG['client_id']}> ", CONFIG['prefix']],
                                          ignore_bots: false

puts 'Initial Startup complete, loading all plugins...'

Starttime = Time.now

Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each { |file| require file }

Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each do |wow|
  bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
  command = bob[0][7..bob[0].length]
  command.delete!("\n")
  command = Object.const_get(command)
  Bot.include! command
  puts "Plugin #{command} successfully loaded!"
end

puts 'Done loading plugins! Finalizing start-up'

Bot.message(contains: /alexa(,|) issue/i, in: 460_832_452_676_550_656) do |event|
  message = event.message.content
  author = if event.user.name == 'CloudCityMC'
             message.split(' » ')[0].split(' ').last
           else
             event.user.distinct
           end
  error = if event.user.name == 'CloudCityMC'
            event.message.content.split(' » ').last
          else
            message[message.index(/alexa(,|) issue/i) + 12..-1]
          end
  error = error.gsub(/alexa(,|) issue/i, '')
  Bot.channel(473_272_276_817_805_312).send_embed do |embed|
    embed.title = 'New issue reported'
    embed.colour = '4A90E2'
    embed.description = error
    embed.timestamp = Time.at(1_532_909_161)

    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Issue reported by #{author}")
  end
  event.respond "issue reported, thanks mate! please note if that issue was spam, you're getting banned, bucko"
end

puts 'Bot is ready!'
Bot.run
