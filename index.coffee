path = require "path"
packager = require "./lib/packager.coffee"
module.exports = (sourceFolder) ->
  sourceFolder = path.normalize sourceFolder 
  new packager(sourceFolder)
