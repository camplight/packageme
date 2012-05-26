module.exports = 
  getCacheKey: (options) ->
    return options.format+"-"+options.source.join("-")
    
  contains: (key) ->
    return @[key] != undefined

  getCachedData: (key) ->
    return @[key]

  write: (key, data) ->
    if typeof @[key] == "undefined"
      @[key] = ""
    @[key] += data