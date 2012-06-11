describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package html source file", (done) ->
    options =
      source: __dirname+"/testData/template.html"
      format: "html"

    sampleData = '<script type="html/template" id="template">\n  Hello World\n</script>\n'

    packageme(options).toString (data) ->
      expect(data).toEqual sampleData
      done()

  it "should be able to package html source folder", (done) ->
    options =
      source: __dirname+"/testData/templates/"
      format: "html"

    sampleData = '<script type="html/template" id="templates-template1">\n  Hello\n</script>\n'
    sampleData += '<script type="html/template" id="templates-template2">\n  World\n</script>\n'

    packageme(options).toString (data) ->
      expect(data).toEqual sampleData
      done()