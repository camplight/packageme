require("coffee-script");
var Package = require("./lib/Package.coffee");

module.exports = function (inputOptions) {
  var options = inputOptions || {

  }

  if(typeof inputOptions == "string") {
    options = {};
    options.source = [inputOptions];
  }

  if(Array.isArray(inputOptions))
    options.source = inputOptions;

  if(typeof inputOptions.sourceFolder != "undefined") // backward compatability :?
    options.source = inputOptions.sourceFolder; 

  if(typeof inputOptions.source == "string")
    options.source = [inputOptions.source]
      
  // use as default javascript format
  options.format = inputOptions.format || "js";

  if(typeof inputOptions.render == "undefined")
    options.render = (options.format == "js" || options.format == "coffee")?"packageme":"";
  
  return new Package(options);
}
