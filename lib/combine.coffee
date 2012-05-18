glob = require "glob"
_ = require "underscore"
fs = require "fs"
path = require "path"
replaceAll = require "./replaceAll.coffee"

render = (templateData, data) ->
  for key of data
    templateData = replaceAll("%"+key+"%", templateData, data[key])
  return templateData

combine = (root, files, type, contextName, resultHandler) ->
  total = files.length
    # console.log "total "+type+" files "+total

  result = ""
  if total == 0
    resultHandler(result)

  fs.readFile __dirname + "/browser-src/codeblock." + type, "utf-8", (err, codeblockTemplate) ->
    _.each files, (filePath) ->

      fs.readFile root+filePath, "utf-8", (err, code) =>
        throw err if err

        # check is the file located within the root, if so do not write path
        if filePath.indexOf("/") != -1
          browserPath = path.dirname(filePath) + "/"
        else
          browserPath = ""

        # indend the code accodingly to the codeblock, its not perfect but works
        if type == "js" or type == "coffee"
          code = code.split("\n").join("\n    ")
        if type == "html" 
          code = code.split("\n").join("\n  ")
          browserPath = browserPath.replace("/", "-")

        # render code with the template
        data = 
          context: contextName 
          path: browserPath
          name: path.basename(filePath, "." + type) 
          code: code

        result += render(codeblockTemplate, data)
        result += "\n"

        total -= 1
        if total == 0
          resultHandler(result)

module.exports = (sourceRoot, order, extension, contextName, resultHandler) ->
  # check and combine/render single file
  if sourceRoot.indexOf("."+extension) != -1
    file = sourceRoot.replace(path.dirname(sourceRoot)+"/", "")
    files = [file]
    combine path.dirname(sourceRoot)+"/", files, extension, contextName, resultHandler
    return

  # add trailing slash if missing
  if sourceRoot[sourceRoot.length-1] != "/"
    sourceRoot += "/"
  
  # save current dir and change it to sourceRoot due glob inner workins :?
  cwd = process.cwd()
  process.chdir path.dirname(sourceRoot)

  glob sourceRoot + "**/*." + extension, (err, files) ->
    process.chdir(cwd)
    throw err if err

    if typeof order != "undefined"
      files = _.sortBy files, (file) ->
        _.indexOf order, file        
      files = files.reverse()

    combine path.dirname(sourceRoot)+"/", files, extension, contextName, resultHandler