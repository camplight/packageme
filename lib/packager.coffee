path = require "path"
combine = require "./combine.coffee"
spawn = require('child_process').spawn
fs = require 'fs'

module.exports = class Packager
  constructor: (@sourceFolder) ->

  pipe: (stream) ->
    fs.readFile __dirname + "/browser-src/packageme.js", (err, packagemeLibrary) =>
      throw err if err

      #console.log "got packagemeLibrary code"
      stream.write packagemeLibrary + "\n"

      combine @sourceFolder, "js", (javascriptCombined) =>
        #console.log "got combined javascript"
        stream.write javascriptCombined + "\n"

        combine @sourceFolder, "coffee", (coffeeCombined) =>  
          #console.log "got combined coffee script"  
          coffeeGenerated = ""

          coffee  = spawn 'coffee', "--compile --stdio".split(" ")
          coffee.stdin.write coffeeCombined
          coffee.stdin.end()

          coffee.stdout.on 'data', (data) ->
            coffeeGenerated += data.toString()

          coffee.stderr.on 'data',  (data) ->
            console.log 'coffee stderr: ' + data

          coffee.on 'exit', (code) ->
            if code != 0
              console.log 'coffee process exited with code ' + code
            
            stream.write coffeeGenerated + "\n"
            stream.end()

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
      console.log "writing to file " + destinationFile
      fs.writeFile(destinationFile, result, resultHandler)

  toURI: (rootURI) ->
    return (req, res, next) =>
      if req.url == rootURI
        res.header "content-type", "text/javascript"
        @pipe res
      else
        next()
