require "sinatra"
require 'sinatra/reloader' if development?

require 'alexa_skills_ruby'
require 'httparty'
require 'iso8601'

# ----------------------------------------------------------------------

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end

# enable sessions for this project
enable :sessions


# ----------------------------------------------------------------------
#     How you handle your Alexa
# ----------------------------------------------------------------------

class CustomHandler < AlexaSkillsRuby::Handler

  on_intent("GetZodiacHoroscopeIntent") do
    slots = request.intent.slots
    response.set_output_speech_text("Horoscope Text")
    #response.set_output_speech_ssml("<speak><p>Horoscope Text</p><p>More Horoscope text</p></speak>")
    response.set_reprompt_speech_text("Reprompt Horoscope Text")
    #response.set_reprompt_speech_ssml("<speak>Reprompt Horoscope Text</speak>")
    response.set_simple_card("title", "content")
    logger.info 'GetZodiacHoroscopeIntent processed'
  end

  on_intent("WHAT") do
		# add a response to Alexa
    response.set_output_speech_text("I am Soul Wanderer, a naughty girl who knows everything that can help you to get through boring times. I’m particularly good at tell you crazy and interesting recreational activities in your city. Tell me where you are like “tell soul wanderer that I live in “Pittsburgh”. ")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "What is processed")
		# log the output if needed
    logger.info 'What processed'
  end

  on_intent("BORING") do
		# add a response to Alexa
    # response.set_output_speech_text("I think you are really boring.")
    # response.set_output_speech("Welcome to Sinatra Sampler. I want to tell you a secret. I can't do very much")
    response.set_output_speech_ssml('<speak>Girl, you are really boring. <audio src="soundbank://soundlibrary/human/amzn_sfx_clear_throat_ahem_01"/> But do not be sad. <amazon:effect name="whispered">I can tell you some interesting secrets</amazon:effect> </speak>')
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "Boring is processed")
		# log the output if needed
    logger.info 'Boring processed'
  end

  on_intent("JOKES") do
    array_of_lines = IO.readlines("jokes.txt")
    resp = array_of_lines.sample
		# add a response to Alexa
    response.set_output_speech_text("Ok, boring girl. I tell you something. #{resp} funny, right?")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "Jokes is processed")
		# log the output if needed
    logger.info 'Jokes processed'
  end

  on_intent("EVENTS") do
    array_of_lines = IO.readlines("eventsbegin.txt")
    eventsbegin = array_of_lines.sample
		# add a response to Alexa
    response.set_output_speech_text("#{eventsbegin} #{events_of_pittsburgh}. Go! Darling! Love you!")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "Envents is processed")
		# log the output if needed
    logger.info 'Envents processed'
  end

  on_intent("CITY_TEST") do

		# Access the slots
    slots = request.intent.slots
    puts slots.to_s

    cityname = slots["city"]["value"]
    cityname = slots["city"].to_s

    #cityname = request.intent.slots.city.["name"]

    array_of_lines = IO.readlines("eventsbegin.txt")
    eventsbegin = array_of_lines.sample


    response.set_output_speech_text("You are at #{cityname}. #{eventsbegin} #{events_of_pittsburgh(cityname)}. Go! Darling! Love you!")
    response.set_simple_card("Soul Wanderer", "City test is processed")
    logger.info 'City test processed'
  end

  on_intent("BAD_BOT") do
    response.set_output_speech_text("Kidding me? I’m robot, smarter and more efficient than your human brain. Want more function? No way, and you're naughty than me! Bahahaha, just kidding! Please give the talent developer, Seven, more time to develop me. Thanks! She is really telant. Tell me where you are like “tell soul wanderer that I live in “Pittsburgh” to get more interesting events around.")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "Badbot is processed")
		# log the output if neededy
    logger.info 'Badbot processed'
  end

end

# ----------------------------------------------------------------------
#     ROUTES, END POINTS AND ACTIONS
# ----------------------------------------------------------------------


get '/' do
  404
end


# THE APPLICATION ID CAN BE FOUND IN THE


post '/incoming/alexa' do
  content_type :json

  handler = CustomHandler.new(application_id: ENV['ALEXA_APPLICATION_ID'], logger: logger)

  begin
    hdrs = { 'Signature' => request.env['HTTP_SIGNATURE'], 'SignatureCertChainUrl' => request.env['HTTP_SIGNATURECERTCHAINURL'] }
    handler.handle(request.body.read, hdrs)
  rescue AlexaSkillsRuby::Error => e
    logger.error e.to_s
    403
  end

end



# ----------------------------------------------------------------------
#     ERRORS
# ----------------------------------------------------------------------



error 401 do
  "Not allowed!!!"
end

# ----------------------------------------------------------------------
#   METHODS
#   Add any custom methods below
# ----------------------------------------------------------------------
def events_of_pittsburgh (cityname)

  ticketmaster_url = "https://app.ticketmaster.com/discovery/v2/events.json?preferredCountry=us&radius=10&unit=miles&city=#{cityname}&apikey=iBBPldGGNG4E7bUFw79GZwPc0goLo1nf"
  response = HTTParty.get( ticketmaster_url )


  #JSON.parse( )
  response["page"].to_json

  event = response["_embedded"]["events"].sample
  resp_str = ""
  resp_str += "Here is a interesting event called #{event["name"]}. The address is #{event["_embedded"]["venues"][0]["address"]["line1"]}"
  # order = 0
  # for event in response["_embedded"]["events"]
  #   order = order + 1
  #   resp_str += "#{order.to_s}. [#{event["name"]}]. Time: [#{event["dates"]["start"]["localDate"]}, #{event["dates"]["start"]["localTime"]}] . <br/>"
  # end
  return resp_str

end

private
