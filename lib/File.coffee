path = require("path")
_ = require("underscore")

module.exports = class File
  extension: ""
  fullPath: ""
  relativePath: ""
  name: ""
  constructor: (attributes)->
    if attributes
      _.extend(@, attributes)
    @fullPath = path.normalize(@fullPath)