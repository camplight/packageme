glob = require "glob"
_ = require "underscore"
fs = require "fs"
path = require "path"
replaceAll = require "./replaceAll.coffee"

render = (templateData, data) ->
  for key of data
    templateData = replaceAll("%"+key+"%", templateData, data[key])
  return templateData

module.exports = (options, files, done) ->
  total = files.length

  result = ""
  if total == 0
    done(result)
    return

  fs.readFile __dirname + "/browser-src/codeblock."+options.format, "utf-8", (err, codeblockTemplate) ->
    _.each files, (file) ->
      fs.readFile file.fullPath, "utf-8", (err, code) =>
        throw err if err

        # indend the code accodingly to the codeblock, its not perfect but works
        if options.indentLines
          code = code.split("\n").join("\n"+options.indentLines)

        # render code with the template
        data = 
          context: options.contextName
          path: file.relativePath
          name: file.name
          code: code

        result += render(codeblockTemplate, data)
        result += "\n"

        # decrease total files found and emit done once no more files are left to render
        total -= 1
        if total == 0
          done(result)