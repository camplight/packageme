fs = require "fs"

module.exports = (format, done)->
  filePath = __dirname + "/browser-src/codeblock."+format
    
  fs.readFile filePath, "utf-8", (err, codeblockTemplate) ->
    done(codeblockTemplate)