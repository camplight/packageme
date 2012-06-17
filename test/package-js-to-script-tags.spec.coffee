httpMocks = require "node-mocks-http"

describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package javascript to script tags", (done) ->
    myFile = 
      fullPath: (__dirname+"/testData/code.js")
      relativePath: "bla/"
      name: "test"
      extension: "js"

    files = []
    files.push(myFile)

    options =
      source: files

    packageme(options).toScriptTags (data) ->
      data = data.toString()
      expect(data).toContain "<script"
      expect(data).toContain "src="
      expect(data).toContain "/packageme.js"
      expect(data).toContain "/bla/test.js"
      done()

  it "should be able to serve javascript script tags as static files", (done) ->
    myFile = 
      fullPath: (__dirname+"/testData/code.js")
      relativePath: "bla/"
      name: "test"
      extension: "js"

    files = []
    files.push(myFile)

    options =
      source: files

    request  = httpMocks.createRequest
      method: 'GET',
      url: '/bla/test.js'
    response = httpMocks.createResponse()
    response.send = (data) ->
      expect(data).toContain "Hello World"
      expect(data).toContain "packageme.register"
      done();

    packageme(options).serveFile request, response

  it "should be able to serve javascript packageme lib as static file", (done) ->
    myFile = 
      fullPath: (__dirname+"/testData/code.js")
      relativePath: "bla/"
      name: "test"
      extension: "js"

    files = []
    files.push(myFile)

    options =
      source: files

    request  = httpMocks.createRequest
      method: 'GET',
      url: '/packageme.js'
    response = httpMocks.createResponse()
    response.end = () ->
      expect(response._getData()).toContain "packageme"
      expect(response._getData()).toContain "normalizePath"
      done();

    packageme(options).serveFile request, response

  it "should be able to register javascript static files handlers in express app", (done) ->
    myFile = 
      fullPath: (__dirname+"/testData/code.js")
      relativePath: "bla/"
      name: "test"
      extension: "js"

    files = []
    files.push(myFile)

    options =
      source: files

    app = 
      handlers : []
      get : (url, handler) ->
        @handlers[url] = handler
      route : (url) ->
        @handlers[url]

    packageme(options).serveFilesToExpress app
    expect(app.route("/*.js")).toBeDefined()
    done()