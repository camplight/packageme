fs = require "fs"
replaceAll = require "./replaceAll"

exports.renderPackageMe = (options, stream, done) ->
  fs.readFile __dirname + "/browser-src/packageme.js", (err, packagemeLibrary) =>
    throw err if err
    packagemeLibrary = replaceAll("%context%", packagemeLibrary.toString(), options.contextName)
    stream.write packagemeLibrary + "\n"
    done()

exports.rencderMainRequire = (options, stream, done) ->
  stream.write options.contextName+".packageme.require('" +options.main+"');\n"
  done()