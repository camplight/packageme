require("coffee-script");
var path = require("path");
var packager = require("./lib/packager.coffee");

module.exports = function (sourceFolder, contextName) {
  sourceFolder = path.normalize(sourceFolder);
  return new packager(sourceFolder, contextName);
}
