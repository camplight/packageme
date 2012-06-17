loadTemplate = require "./loadTemplate"
renderFile = require "./renderFile"
_ = require "underscore"

module.exports = (files, renderOptions, done) ->
  total = files.length

  result = ""
  if total == 0
    done(result)
    return
    
  loadTemplate renderOptions.format, (codeblockTemplate)->
    _.each files, (file) ->
      renderFile file, codeblockTemplate, renderOptions, (fileData) ->
        # render code with the template
        result += fileData
        result += "\n"
        # decrease total files found and emit done once no more files are left to render
        total -= 1
        if total == 0
          done(result)