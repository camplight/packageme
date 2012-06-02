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
    
    # check folder for extension 
    # and if it has such matching to target files
    # just append to collected files and return 
    ext = path.extname(folder)
    if ext == "."+options.format
      f = new File()
      f.name = path.basename(folder, "."+options.format)
      f.relativePath = ""
      f.fullPath = folder
      f.extension = options.format

      result.push(f)
      total -= 1
      if total == 0
        done(result)
      return

    if(folder.lastIndexOf("/") != folder.length-1)
      folder += "/"
    
    folder = path.normalize(folder)

    # weird but true
    cwd = process.cwd()
    process.chdir(path.dirname(folder))

    glob folder + "**/*." + options.format, (err, files) ->
      throw err if err

      # still 
      process.chdir(cwd)

      if typeof options.order != "undefined"
        files = _.sortBy files, (file) -> _.indexOf options.order, file
        files = files.reverse()

      _.each files, (file) -> 
        f = new File()
        f.name = path.basename(file, "."+options.format)
        f.relativePath = path.dirname(file)+"/"
        f.fullPath = path.dirname(folder)+"/"+file
        f.extension = options.format

        result.push(f)

      total -= 1
      if total == 0
        done(result)