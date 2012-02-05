#!/usr/bin/env coffee
express = require 'express'
package = require 'packageme'

app = module.exports = express.createServer()

app.configure () ->
  app.use express.bodyParser() 
  app.use express.methodOverride()
  app.use package(__dirname).toURI("/code.js")
  app.use app.router
  app.use express.static __dirname

app.configure 'development', () ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.use express.errorHandler()

app.listen 8000
console.log "test server listening on port #{app.address().port} in #{app.settings.env} mode"
