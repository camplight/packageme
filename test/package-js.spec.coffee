describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package javascript source file", (done) ->
    options =
      source: __dirname+"/testData/code.js"

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      done()

  it "should be able to package javascript source folder", (done) ->
    options =
      source: __dirname+"/testData/javascript/"

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      expect(data).toContain "Hello World2"
      done()

  it "should be able to package coffeescript source file", (done) ->
    options =
      source: __dirname+"/testData/code.coffee"

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      done()

  it "should be able to package coffeescript source folder", (done) ->
    options =
      source: __dirname+"/testData/coffeescript/"

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      expect(data).toContain "Hello World2"
      done()