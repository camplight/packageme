path = require "path"
combine = require "./combine.coffee"
spawn = require('child_process').spawn
fs = require 'fs'
replaceAll = require "./replaceAll.coffee"

module.exports = class Packager
  constructor: (@sourceFolder, @contextName = "window") ->

  readPackage: (handle) ->
    path.exists @sourceFolder+"/package.json", (exists) =>
      if exists
        handle require(@sourceFolder+"/package.json") 
      else
        path.exists @sourceFolder+"/jspackage.json", (exists) =>
          if exists
            handle require(@sourceFolder+"/jspackage.json")
          else
            handle null

  writeMain: (mainPath, stream) ->
    stream.write @contextName+".packageme.require('" +path.basename(path.normalize(@sourceFolder))+"/"+mainPath+"');\n"

  pipe: (stream) ->
    @readPackage (package) =>

      fs.readFile __dirname + "/browser-src/packageme.js", (err, packagemeLibrary) =>
        throw err if err
        packagemeLibrary = replaceAll("%context%", packagemeLibrary.toString(), @contextName)

        #console.log "got packagemeLibrary code"
        stream.write packagemeLibrary + "\n"

        combine @sourceFolder, "js", @contextName, (javascriptCombined) =>
          #console.log "got combined javascript"
          stream.write javascriptCombined + "\n"

          combine @sourceFolder, "coffee", @contextName, (coffeeCombined) =>  
            #console.log "got combined coffee script"  
            coffeeGenerated = ""

            coffee  = spawn 'coffee', "--compile --stdio".split(" ")
            coffee.stdin.write coffeeCombined
            coffee.stdin.end()

            coffee.stdout.on 'data', (data) ->
              coffeeGenerated += data.toString()

            coffee.stderr.on 'data',  (data) ->
              console.log 'coffee stderr: ' + data

            coffee.on 'exit', (code) =>
              if code != 0
                console.log 'coffee process exited with code ' + code
              
              stream.write coffeeGenerated + "\n"
              @writeMain(package.main, stream) if package and package.main
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
      fs.writeFile(destinationFile, result, resultHandler)

  toURI: (rootURI) ->
    return (req, res, next) =>
      if req.url == rootURI
        res.header "content-type", "text/javascript"
        @pipe res
      else
        next()
