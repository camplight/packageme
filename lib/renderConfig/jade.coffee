_ = require "underscore"
jade = require 'jade'

module.exports = (options) ->
  defaults = 
    indentLines: "  "
    prerender: (data, done) -> 
      data.path = data.path.replace("/", "-")
      done(data)
    postrender: (jadeCombined, done)->
      fn = jade.compile jadeCombined, options
      compiled = fn(options.locals || {})
      done(compiled)

  _.extend defaults, options