fs = require "fs"
replaceAll = require "./replaceAll.coffee"
_ = require "underscore"

render = (templateData, data) ->
  for key of data
    if typeof data[key] == "string"
      templateData = replaceAll("%"+key+"%", templateData, data[key])
  return templateData


module.exports = (file, codeblockTemplate, renderOptions, done) ->
  fs.readFile file.fullPath, "utf-8", (err, code) ->
    throw err if err

    if renderOptions.indentLines
      code = code.split("\n").join("\n"+renderOptions.indentLines)

    data = 
      path: file.relativePath
      name: file.name
      code: code

    data = _.extend data, renderOptions

    finish = (renderedFile) ->
      if renderOptions.postrender
        renderOptions.postrender renderedFile, (result) ->
          done(result)
      else
        done(renderedFile)


    if renderOptions.prerender
      renderOptions.prerender data, (processedData) ->
        finish(render(codeblockTemplate, processedData))
    else
      finish(render(codeblockTemplate, data))

    