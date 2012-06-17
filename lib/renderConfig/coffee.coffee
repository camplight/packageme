_ = require "underscore"
CoffeeScript = require 'coffee-script'

module.exports = (options) ->
  defaults = 
    context: "window"
    indentLines: "    "
    postrender: (coffeeCombined, done)->
      compiled = CoffeeScript.compile coffeeCombined
      done(compiled)
      
  _.extend defaults, options