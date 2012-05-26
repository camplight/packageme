render = require "../render.coffee"
_ = require "underscore"

module.exports = (options, stream) ->
  # clone options with specific css related params
  options = _.extend(options, {format: "css"})

  render options, options.files, (result) ->
    stream.write(result)
    stream.end()