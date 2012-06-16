describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package javascript source file", (done) ->
    myFile = 
      fullPath: (__dirname+"/testData/code.js")
      relativePath: "bla/"
      name: "test"
      extension: "js"

    files = []
    files.push(myFile)

    options =
      source: files

    packageme(options).toString (data) ->
      expect(data).toContain "Hello World"
      done()