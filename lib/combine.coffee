glob = require "glob"
_ = require "underscore"
fs = require "fs"
path = require "path"

replaceAll = (pattern, target, replacement, ignore) ->
  target.replace(new RegExp(pattern.replace(/([\/\,\!\\\^\$\{\}\[\]\(\)\.\*\+\?\|\<\>\-\&])/g,"\\$&"),"g"),replacement.replace(/\$/g,"$$$$"))

render = (templateData, data) ->
  for key of data
    templateData = replaceAll("%"+key+"%", templateData, data[key])
  return templateData

module.exports = (sourceFolder, order, extension, contextName, resultHandler) ->
  # add trailing slash if missing
  if sourceFolder[sourceFolder.length-1] != "/"
    sourceFolder += "/"
  
  # save current dir and change it to sourceFolder due glob inner workins :?
  cwd = process.cwd()
  process.chdir path.dirname(sourceFolder)

  glob sourceFolder + "**/*." + extension, (err, files) ->
    process.chdir(cwd)

    throw err if err

    total = files.length
    # console.log "total "+extension+" files "+total

    result = ""
    if total == 0
      resultHandler result

    fs.readFile __dirname + "/browser-src/codeblock." + extension, "utf-8", (err, codeblockTemplate) ->

      if typeof order != "undefined"
        files = _.sortBy files, (file) ->
          _.indexOf order, file        
        files = files.reverse()

      _.each files, (filePath) ->

        fs.readFile path.dirname(sourceFolder)+"/"+filePath, "utf-8", (err, code) =>
          throw err if err

          # indend the code accodingly to the codeblock, its not perfect but works
          if extension == "js" or extension == "coffee"
            code = code.split("\n").join("\n    ")
          if extension == "html" 
            code = code.split("\n").join("\n  ")

          # render code with the template
          result += render(codeblockTemplate, { context: contextName, path: path.dirname(filePath) + "/", name: path.basename(filePath, "." + extension), code: code })
          result += "\n"

          total -= 1
          if total == 0
            resultHandler result