render = require "../render.coffee"
_ = require "underscore"
spawn = require('child_process').spawn

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
  coffeeGenerated = ""

  coffee  = spawn 'coffee', "--compile --stdio".split(" ")
  coffee.stdin.write coffeeCombined
  coffee.stdin.end()

  coffee.stdout.on 'data', (data) ->
    coffeeGenerated += data.toString()

  coffee.stderr.on 'data',  (data) ->
    console.log 'coffee stderr: ' + data

  coffee.on 'exit', (code) =>
    throw new Error('coffee process exited with code ' + code) if code != 0
    resultHandler(coffeeGenerated)
