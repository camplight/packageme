snockets = require("snockets")
_ = require("underscore")

module.exports = (options, stream, done) ->
  total = options.source.length
  _.each options.source, (folder) ->
    snockets.getConcatenation folder, minify: options.compile, (err, js) ->
      stream.write(js)
      total -= 1
      done() if total == 0