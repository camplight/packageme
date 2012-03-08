do f = ->
  require = (path) ->
    packageme.require(path, require.path)
  require.path = "%path%"
  exports = {}
  module = {exports: exports}
  packageme.register "%path%%name%", () ->
    %code%
    return module.exports