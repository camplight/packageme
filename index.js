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

  // use as default window context
  options.contextName = inputOptions.contextName || "window";
      
  // use as default javascript format
  options.format = inputOptions.format || "js"

  // use as default caching enabled in production
  if(process.env.NODE_ENV == "production") {
    options.useCache = inputOptions.useCase || true;
  }

  return new Package(options);
}
