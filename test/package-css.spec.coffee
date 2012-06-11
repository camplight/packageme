describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package css source file", (done) ->
    options =
      source: __dirname+"/testData/style.css"
      format: "css"

    sampleData = 'div {margin: auto;}\n'

    packageme(options).toString (data) ->
      expect(data).toEqual sampleData
      done()

  it "should be able to package css source folder", (done) ->
    options =
      source: __dirname+"/testData/styles/"
      format: "css"

    sampleData = 'div {margin: auto;}\n'
    sampleData += 'p {margin: auto;}\n'

    packageme(options).toString (data) ->
      expect(data).toEqual sampleData
      done()