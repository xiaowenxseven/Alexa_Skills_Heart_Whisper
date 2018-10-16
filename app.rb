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
    response.set_output_speech_text("This is the answer of what.")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "What is processed")
		# log the output if needed
    logger.info 'What processed'
  end

  on_intent("BORING") do
		# add a response to Alexa
    response.set_output_speech_text("I think you are really boring.")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "Boring is processed")
		# log the output if needed
    logger.info 'Boring processed'
  end

  on_intent("JOKES") do
    array_of_lines = IO.readlines("jokes.txt")
    resp = array_of_lines.sample
		# add a response to Alexa
    response.set_output_speech_text("Ok, boring girl. I tell you something. #{resp}")
		# create a card response in the alexa app
    response.set_simple_card("Soul Wanderer", "Jokes is processed")
		# log the output if needed
    logger.info 'Jokes processed'
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

private
