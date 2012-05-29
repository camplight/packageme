require("coffee-script");
var Package = require("./lib/Package.coffee");

module.exports = function (options) {
  if(typeof options == "string")
    options = { source: [options] };

  if(Array.isArray(options))
    options = { source: options };

  if(typeof options.sourceFolder != "undefined") {
    options.source = options.sourceFolder; // backward compatability :?
    if(typeof options.source == "string")
      options.source = [options.source]
    options.sourceFolder = undefined;
  }

  // use as default window context
  options.contextName = options.contextName || "window";
      
  // use as default javascript format
  options.format = options.format || "js"

  // use as default caching enabled in production
  if(process.env.NODE_ENV == "production") {
    options.useCache = true;
  }

  return new Package(options);
}
