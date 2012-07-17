describe 'packageme html', ->
  packageme = require "../index"

  it "should be able to package jade source file as html", (done) ->
    options =
      source: __dirname+"/testData/template.jade"
      format: "jade"

    sampleData = '<script id="template" type="html/template"><div class="test">Hello World</div></script>\n'

    packageme(options).toString (data) ->
      expect(data).toEqual sampleData
      done()

  it "should be able to package jade source folder", (done) ->
    options =
      source: __dirname+"/testData/templates/"
      format: "jade"

    sampleData = '<script id="templates-template1" type="html/template"><div class="test">Hello</div></script>\n'
    sampleData += '<script id="templates-template2" type="html/template"><div class="test">World</div></script>\n'

    packageme(options).toString (data) ->
      expect(data).toEqual sampleData
      done()