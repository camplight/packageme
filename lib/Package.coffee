path = require "path"
collect = require "./collect"
fs = require "fs"

module.exports = class Package
  constructor: ( @options ) ->
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

  toExpressURIHandler: () ->
    return (req, res, next) =>
      if @options.format == "js"
        res.header "content-type", "text/javascript"
      if @options.format == "css"
        res.header "content-type", "text/css"
      if @options.format == "html"
        res.header "content-type", "text/html"
      @pipe res

  toExpressMiddleware: (rootURI) ->
    return (req, res, next) =>
      if req.url == rootURI
        if @options.format == "js"
          res.header "content-type", "text/javascript"
        if @options.format == "css"
          res.header "content-type", "text/css"
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
        stream.end()
        return

      buffer = 
        write: (data) =>
          @cache.write(key, data)
          stream.write(data)
        end: ()->
          stream.end()

    if @options.format == "js" || @options.format == "coffee"
      
      if @options.render == "snockets"
        buildSnockets = require("./build/snockets")
        buildSnockets @options, buffer, () =>
          buffer.end()
      return

      packagemeHelper = require("./packagemeHelper")
      buildJavascript = require("./build/js")
      buildCoffee = require("./build/coffee")

      writeEnd = () =>
        if @options.package and @options.package.main 
          packagemeHelper.renderMainRequire @options, buffer, () =>
            buffer.end()
        else
          buffer.end()

      # always render packageme helper code first
      packagemeHelper.renderPackageMe @options, buffer, () =>
        # collect any javascript script files
        @options.format = "js"
        collect @options, (javascriptFiles) =>
          # collect any coffee script files
          @options.format = "coffee"
          collect @options, (coffeeFiles) =>
            # build javascript 
            @options.files = javascriptFiles
            
            buildJavascript @options, buffer, () =>
              # build coffeescript
              @options.files = coffeeFiles
              if coffeeFiles.length == 0
                writeEnd()
              else
                buildCoffee @options, buffer, () =>
                  writeEnd()
    else
      build = require("./build/"+@options.format)
      collect @options, (files) =>
        @options.files = files
        build @options, buffer, () =>
          buffer.end()