glob = require("glob")
_ = require("underscore")
path = require "path"
File = require "./File.coffee"

module.exports = (options, done) ->
  # iterate through all options.source locations/files
  # find all files which are target for collection
  # construct single array with File objects
  result = []

  total = options.source.length

  _.each options.source, (folder) ->
    if(folder.lastIndexOf("/") != folder.length-1)
      folder += "/"
    
    folder = path.normalize(folder)

    cwd = process.cwd()
    process.chdir(path.dirname(folder))
    glob folder + "**/*." + options.format, (err, files) ->
      throw err if err
      process.chdir(cwd)

      if typeof options.order != "undefined"
        files = _.sortBy files, (file) -> _.indexOf options.order, file
        files = files.reverse()

      _.each files, (file) -> result.push(new File(folder, file))

      total -= 1
      if total == 0
        done(result)