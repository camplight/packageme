glob = require("glob")
_ = require("underscore")
fs = require("fs")
path = require("path")

render = (templateData, data) ->
  for key of data
    templateData = templateData.replace(new RegExp("\{"+key+"\}", "g"), data[key])
  return templateData

module.exports = (sourceFolder, extension, resultHandler) ->
  # add trailing slash if missing
  if sourceFolder[sourceFolder.length-1] != "/"
    sourceFolder += "/"
  console.log "combining "+sourceFolder
  
  glob sourceFolder+"**/*."+extension, (err, files)->
    throw err if err

    total = files.length
    console.log "total "+extension+" files "+total

    result = ""
    if total == 0
      resultHandler result

    fs.readFile __dirname+"/browser-src/codeblock."+extension, "utf-8", (err, codeblockTemplate) ->
      _.each files, (filePath) ->
        fs.readFile filePath, "utf-8", (err, code) =>

          # indend the code accodingly to the codeblock
          code = code.split("\n").join("\n    ")

          # render code with the template
          result += render codeblockTemplate, {path: path.dirname(filePath)+"/", name: path.basename(filePath, "."+extension), code: code}
          result += "\n"

          total -= 1
          if total == 0
            resultHandler result