do f = ->
  require = (path, useCache) ->
    %context%.packageme.require(path, useCache, require.path)
  require.path = "%path%"
  exports = {}
  module = {exports: exports}
  %context%.packageme.register "%path%%name%", () ->
    %code%
    return module.exports