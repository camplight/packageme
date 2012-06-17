fs = require "fs"
replaceAll = require "./replaceAll.coffee"
collect = require "./collect"
renderFiles = require "./renderFiles"

module.exports = (sources, renderOptions, buffer, done) ->

  writeEnd = () =>
    if renderOptions.package and renderOptions.package.main 
      buffer.write renderOptions.context+".packageme.require('" +renderOptions.main+"');\n"
    done()
  
  # always render packageme helper code first
  module.exports.writePackageMeLib renderOptions.context, buffer, () ->

    # collect any script files
    collect sources, renderOptions.format, (files) =>

      # render them to buffer
      renderFiles files, renderOptions, (filesData) =>
        buffer.write(filesData)
        done()

module.exports.writePackageMeLib = (contextName, stream, done) ->
  fs.readFile __dirname + "/browser-src/packageme.js", (err, packagemeLibrary) =>
    throw err if err
    packagemeLibrary = replaceAll("%context%", packagemeLibrary.toString(), contextName)
    stream.write packagemeLibrary + "\n"
    done()