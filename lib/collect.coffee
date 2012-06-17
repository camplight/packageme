glob = require("glob")
_ = require("underscore")
path = require "path"
File = require "./File.coffee"

module.exports = (sources, format, done) ->
  # iterate through all sources locations/files
  # find all files which are target for collection
  # construct single array with File objects
  result = []

  total = sources.length
  if total == 0
    done(result)
    return

  sayDone = () ->
    total -= 1
    if total == 0
      done(result)

  _.each sources, (folder) ->
    
    # check folder to be File object
    if typeof folder == "object"
      if folder.extension == format
        result.push(new File(folder))
        sayDone()
      else
        sayDone()
      return
    
    # check folder for extension 
    # and if it has such matching to target files
    # just append to collected files and return 
    ext = path.extname(folder)
    if ext == "."+format
      f = new File()
      f.name = path.basename(folder, "."+format)
      f.relativePath = ""
      f.fullPath = folder
      f.extension = format

      result.push(f)
      sayDone()
      return

    if(folder.lastIndexOf("/") != folder.length-1)
      folder += "/"
    
    folder = path.normalize(folder)

    # weird but true
    cwd = process.cwd()
    
    try
      process.chdir(path.dirname(folder))
    catch err
      throw new Error("Cannot find "+folder+" folder \n"+err)



    glob folder + "**/*." + format, (err, files) ->
      throw err if err

      # still 
      process.chdir(cwd)

      _.each files, (file) -> 
        f = new File()
        f.name = path.basename(file, "."+format)
        f.relativePath = path.dirname(file)+"/"
        f.fullPath = path.dirname(folder)+"/"+file
        f.extension = format

        result.push(f)

      sayDone()