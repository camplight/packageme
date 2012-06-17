_ = require "underscore"

module.exports = (options) ->
  defaults = 
    indentLines: "  "
    prerender: (data, done) -> 
      data.path = data.path.replace("/", "-")
      done(data)

  _.extend defaults, options