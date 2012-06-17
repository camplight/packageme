path = require "path"
collect = require "./collect"
fs = require "fs"
_ = require "underscore"

loadTemplate = require "./loadTemplate"
renderFile = require "./renderFile"
renderFiles = require "./renderFiles"
renderPackageme = require "./renderPackageme"
renderSnockets = require "./renderSnockets"

sendHeader = (res, format) ->
  if format == "js" or format == "coffee"
    res.header "content-type", "text/javascript"
  if format == "css"
    res.header "content-type", "text/css"
  if format == "html"
    res.header "content-type", "text/html"

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
      sendHeader res, @options.format
      @pipe res

  toExpressMiddleware: (rootURI) ->
    return (req, res, next) =>
      if req.url == rootURI
        sendHeader res, @options.format
        @pipe res
      else
        next()

  toScriptTags: (callback) -> 
    result = []
    prefix = @options.prefix || "/"
    
    if @options.compile
      callback(['<script src="'+prefix+'code.js"></script>'])
    else
      result.push('<script src="'+prefix+'packageme.js"></script>')

      # collect any script files
      collect @options.source, @options.format, (javascriptFiles) =>
        _.each javascriptFiles, (file) =>
          result.push('<script src="'+prefix+file.relativePath+file.name+'.js"></script>')
        callback(result)

  toStyleTags: (callback) -> 
    result = []

    prefix = @options.prefix || "/"
    if @options.compile
      callback(['<link href="'+prefix+'style.css" rel="stylesheet"/>'])
    else
      collect @options.source, @options.format, (stylesheets) =>
        _.each stylesheets, (file) =>
          result.push('<link href="'+prefix+file.relativePath+file.name+'.css" rel="stylesheet"/>')
        callback(result)

  serveFile: (req, res, next) ->
    prefix = @options.prefix || "/"
    if @options.compile
      sendHeader res, @options.format
      @pipe res
    else
      if req.url == prefix+'packageme.js'
        context = @options.context || "window"
        sendHeader res, "js"
        renderPackageme.writePackageMeLib context, res, () =>
          res.end()
      else
        collect @options.source, @options.format, (files) =>
          for file in files
            fileUrl = prefix+file.relativePath+file.name+"."+@options.format
            if fileUrl == req.url
              loadTemplate @options.format, (codeTemplate) =>
                configure = require "./renderConfig/"+@options.format
                renderFile file, codeTemplate, configure(@options), (fileData) =>
                  sendHeader res, @options.format
                  res.send(fileData)

              # return as request was matched
              return

          # call next only if there is no match found after checking all collected files
          next()

  serveFilesToExpress: (app) ->
    prefix = @options.prefix || "/"

    if @options.compile
      if @options.format == "css"
        app.get prefix+"style.css", (req, res, next) => @serveFile(req, res, next)
      else
      if @options.format == "js" || @options.format == "coffee"
        app.get prefix+"code.js", (req, res, next) => @serveFile(req, res, next)
    else
      app.get prefix+"*."+@options.format, (req, res, next) => @serveFile(req, res, next)

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

    if @options.render == "snockets"
      renderSnockets @options, buffer, () =>
        buffer.end()
    else
    if @options.render == "packageme"
      configure = require "./renderConfig/"+@options.format
      renderPackageme @options.source, configure(@options), buffer, () =>
        buffer.end()
    else
      collect @options.source, @options.format, (files) =>
        configure = require "./renderConfig/"+@options.format
        renderFiles files, configure(@options), (filesData) =>
          buffer.write(filesData)
          buffer.end()