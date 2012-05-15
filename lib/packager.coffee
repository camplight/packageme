_ = require("underscore")
path = require "path"
combine = require "./combine.coffee"
spawn = require('child_process').spawn
fs = require 'fs'
replaceAll = require "./replaceAll.coffee"

module.exports = class Packager
  constructor: ( options ) ->
    if typeof options == "string"
      options = { sourceFolder: options }
    if Array.isArray(options)
      options = { sourceFolder: options }

    @options = options
    # use as default window context
    @options.contextName ?= "window"

  toString: (resultHandler) ->
    # simulate stream
    buffer =
      str: ""
      write: (data) ->
        @str += data
      end: ()->
        resultHandler @str
    @pipe buffer
          
  toFile: (destinationFile, resultHandler) ->
    destinationFile = path.normalize destinationFile
    @toString (result) ->
      fs.writeFile(destinationFile, result, resultHandler)

  toURI: (rootURI) ->
    return (req, res, next) =>
      if req.url == rootURI
        res.header "content-type", "text/javascript"
        @pipe res
      else
        next()

  readPackage: (options, handle) ->
    path.exists options.sourceFolder+"/package.json", (exists) =>
      if exists
        handle require(options.sourceFolder+"/package.json") 
      else
        path.exists options.sourceFolder+"/jspackage.json", (exists) =>
          if exists
            handle require(options.sourceFolder+"/jspackage.json")
          else
            handle null

  writePackageMeLibAt: (stream, options, done) ->
    fs.readFile __dirname + "/browser-src/packageme.js", (err, packagemeLibrary) =>
      throw err if err
      packagemeLibrary = replaceAll("%context%", packagemeLibrary.toString(), options.contextName)
      stream.write packagemeLibrary + "\n"
      done()

  writeFoundJavascriptAt: (stream, options, done) ->
    if options.package
      order = options.package.order
    combine options.sourceFolder, order, "js", options.contextName, (javascriptCombined) =>
      stream.write javascriptCombined + "\n"
      done()

  compileCoffee: (coffeeCombined, resultHandler) ->
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

  writeFoundCoffeeAt: (stream, options, done) ->
    if options.package
      order = options.package.order
    combine options.sourceFolder, order, "coffee", options.contextName, (coffeeCombined) =>  
      if coffeeCombined.length == 0
        done()
      else
        @compileCoffee coffeeCombined, (coffeeGenerated) =>
          stream.write coffeeGenerated + "\n"
          done()

  writeMainAt: (stream, options) ->
    if options.package and options.package.main
      mainEntryPoint = path.basename(path.normalize(options.sourceFolder))+"/"+options.package.main
      stream.write options.contextName+".packageme.require('" +mainEntryPoint+"');\n"

  writeSourceFolderAt: (stream, options, done) ->
    @readPackage options, (p) =>
      # inject current source folder's package into options
      options.package = p
      @writeFoundJavascriptAt stream, options, () =>
        @writeFoundCoffeeAt stream, options, () =>
          @writeMainAt stream, options
          done()

  pipe: (stream) ->
    @writePackageMeLibAt stream, @options, () =>
      if Array.isArray(@options.sourceFolder)

        # reference when writing is finished
        count = @options.sourceFolder.length

        # iterates in each sourceFolder and writes to stream in async way
        _.each @options.sourceFolder, (folder) =>
          options = _.extend {}, @options
          options.sourceFolder = folder
          @writeSourceFolderAt stream, options, () =>
            count -= 1
            if count == 0
              stream.end()

      else
        @writeSourceFolderAt stream, @options, () =>
          stream.end()