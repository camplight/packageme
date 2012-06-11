render = require "../render.coffee"
_ = require "underscore"
CoffeeScript = require 'coffee-script'

module.exports = (options, stream, done) ->
  # clone options with specific coffee script related params
  options = _.extend(options, {format: "coffee", indentLines: "    "})

  # render to single string
  render options, options.files, (result) ->
    
    # compile the coffee to javascript and only then write the result to stream
    compileCoffee result, (compiled) ->
      stream.write(compiled+"\n")
      done()

compileCoffee = (coffeeCombined, resultHandler) ->
  compiled = CoffeeScript.compile coffeeCombined
  resultHandler(compiled)