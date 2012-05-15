require("coffee-script");
var path = require("path");
var packager = require("./lib/packager.coffee");

module.exports = function (options) {
  return new packager(options);
}
