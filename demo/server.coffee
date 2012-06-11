#!/usr/bin/env coffee
express = require 'express'
packageme = require 'packageme'

app = module.exports = express.createServer()
app.set("views", __dirname);
app.set('view engine', 'jade');

app.configure () ->
  app.use express.bodyParser() 
  app.use express.methodOverride()
  app.use packageme([__dirname+"/assets", __dirname+"/controllers"]).toExpressMiddleware("/code.js")
  app.use app.router
  app.use express.static __dirname+"/assets"

app.configure 'development', () ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.use express.errorHandler()

app.get "/", (req, res, next) ->
  res.render("index", {layout: false})

app.listen 8000
console.log "test server listening on port #{app.address().port} in #{app.settings.env} mode"
