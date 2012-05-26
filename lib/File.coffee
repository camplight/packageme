path = require("path")

module.exports = class File
  extension: ""
  fullPath: ""
  relativePath: ""

  constructor: (root, file)->
    @extension = path.extname(file)
    @fullPath = path.normalize(path.dirname(root)+"/"+file)
    @relativePath = path.dirname(file)
    @name = path.basename(@fullPath, @extension) 
    if @relativePath.lastIndexOf("/") != @relativePath.length-1
      @relativePath += "/"