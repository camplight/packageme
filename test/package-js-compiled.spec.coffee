describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package javascript source file compiled", (done) ->
    options =
      source: __dirname+"/testData/code.js"
      compile: true

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      done()

  it "should be able to package javascript source folder compiled", (done) ->
    options =
      source: __dirname+"/testData/javascript/"
      compile: true

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      expect(data).toContain "Hello World2"
      done()

  it "should be able to package coffeescript source file compiled", (done) ->
    options =
      source: __dirname+"/testData/code.coffee"
      format: "coffee"
      compile: true

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      done()

  it "should be able to package coffeescript source folder compiled", (done) ->
    options =
      source: __dirname+"/testData/coffeescript/"
      format: "coffee"
      compile: true

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      expect(data).toContain "Hello World2"
      done()