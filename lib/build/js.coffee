render = require "../render.coffee"
replaceAll = require "../replaceAll.coffee"
_ = require "underscore"
spawn = require('child_process').spawn
fs = require 'fs'

renderPackageMe = (options, stream, done) ->
  fs.readFile __dirname + "/../browser-src/packageme.js", (err, packagemeLibrary) =>
    throw err if err
    packagemeLibrary = replaceAll("%context%", packagemeLibrary.toString(), options.contextName)
    stream.write packagemeLibrary + "\n"
    done()

rencderMainRequire = (options, stream) ->
  stream.write options.contextName+".packageme.require('" +options.main+"');\n"

renderJavascript = (options, stream, done) ->
  # clone options with specific javascript related params
  options = _.extend(options, {format: "js", indentLines: "    "})
  
  # extract only found javascript files
  files = _.filter(options.files, (f) -> f.extension == ".js")

  # render to single string and write to stream
  render options, files, (result) ->
    stream.write(result+"\n")
    done()

renderCoffeescript = (options, stream, done) ->
  # clone options with specific coffee script related params
  options = _.extend(options, {format: "coffee", indentLines: "    "})
  
  # extract only found coffeescript files
  files = _.filter(options.files, (f) -> f.extension == ".coffee")

  # render to single string
  render options, files, (result) ->
    
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

module.exports = (options, stream) ->
  # always render packageme lib first
  renderPackageMe options, stream, () ->

    # render all javascript files
    renderJavascript options, stream, () ->

      # and coffee script ones
      renderCoffeescript options, stream, () ->

        # at the end write an require statement if there is package.main defined in options
        if options.package and options.package.main 
          renderMainRequire options, stream

        # end the stream
        stream.end()