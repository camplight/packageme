path = require "path"
collect = require "./collect"
fs = require "fs"

module.exports = class Package
  constructor: ( @options ) ->

    # use as default window context
    @options.contextName ?= "window"
    
    # use as default javascript format
    @options.format ?= "js"

    @cache = require("./cache.coffee")

  toString: (resultHandler) ->
    result = ""
    buffer =
      write: (data) ->
        result += data
      end: ()->
        resultHandler(result)
    @pipe buffer

  toFile: (destinationFile, resultHandler) ->
    destinationFile = path.normalize destinationFile
    @toString (result) ->
      fs.writeFile(destinationFile, result, resultHandler)

  toExpressMiddleware: (rootURI) ->
    return (req, res, next) =>
      if req.url == rootURI
        if @options.format == "js"
          res.header "content-type", "text/javascript"
        if @options.format == "css"
          res.header "content-type", "text/stylesheet"
        if @options.format == "html"
          res.header "content-type", "text/html"
        @pipe res
      else
        next()

  pipe: (stream) ->
    buffer = stream
    
    if @options.useCache
      key = @cache.getCacheKey(@options)
      if @cache.contains(key)
        stream.write(@cache.getCachedData(key))
        return

      buffer = 
        write: (data) ->
          @cache.write(key, data)
          stream.write(data)
        end: ()->
          stream.end()

    # get current format builder, note javascript/coffeescript uses the same builder
    build = require("./build/"+@options.format)

    collect @options, (files) =>
      # inject collected files into options
      @options.files = files

      if @options.format == "js"
        @options.format = "coffee"
        collect @options, (files) =>
          @options.files = @options.files.concat(files)
          # build given options by writing to buffer
          build @options, buffer
      else
        # build given options by writing to buffer
        build @options, buffer