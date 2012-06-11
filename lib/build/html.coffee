render = require "../render.coffee"
_ = require "underscore"

module.exports = (options, stream, done) ->
  # clone options with specific html related params
  options = _.extend(options, {format: "html", indentLines: "  "})

  # update files' relative paths so that they are rendered with valid DOMselectable ids
  options.files = _.map options.files, (file) -> 
    file.relativePath = file.relativePath.replace("/", "-")
    return file

  render options, options.files, (result) ->
    stream.write(result)
    done()