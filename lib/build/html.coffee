render = require "../render.coffee"
_ = require "underscore"

module.exports = (options, stream, done) ->
  # clone options with specific html related params
  options = _.extend(options, {format: "html", indentLines: "  "})

  render options, options.files, (result) ->
    stream.write(result)
    done()