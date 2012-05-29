render = require "../render.coffee"
_ = require "underscore"

module.exports = (options, stream, done) ->
  # clone options with specific javascript related params
  options = _.extend(options, {format: "js", indentLines: "    "})

  # render to single string and write to stream
  render options, options.files, (result) ->
    stream.write(result+"\n")
    done()