_ = require "underscore"

module.exports = (options) ->
  defaults = 
    indentLines: "    "
    context: "window"
    
  _.extend defaults, options
    