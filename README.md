# Package.Me #

  * Command-line tool 
  * module 
  * express-like middleware 

for packaging of javascript, coffeescript & other^script code within a folder structure to

  * memory at runtime for development
  * file for production

Inspired by nibjs, following CommonJS, packages can be distributed via npm.

## usage as command-line tool ##

follwing will take sourceFolder/package.json and combine all supported scripts to destinationFile

    packageme sourceFolder destinationFile

## usage as nodejs module ##

    var package = require("packageme");
  
    // will write sourceFolder to destinationFile, invoking resultHandler on end
    package(sourceFolder).toFile(destinationFile, resultHandler); 
  
    // will write sourceFolder to string, invoking resultHandler(string) on end
    package(sourceFolder).toString(resultHandler);
  
    // will pipe the sourceFolder to string, will invoke stream.end() once finished.
    package(sourceFolder).pipe(stream);

## usage as express middleware ##

    // will return sourceFolder packaged at URI /packages/packageName based on sourceFolder/package.json
    // toURI respects the NODE_ENV flag, and will optimize package process in production mode to happen only once.
    app.configure(function(){
      app.use(package(sourceFolder).toURI("/packages/packageName"));
      app.use(app.router);
    });

## in browser usage ##

    // will return module instance of packageName's main module.
    var library = packageme.require("packageName");
  
    // will return module instance of moduleA within package 'packageName'
    var module = packageme.require("packageName/libs/moduleA");
  
    // require statements act as they should even within modules
    // requires respect the actual sever-side structure of the code, nevertheless they are emulated within the browser.
    var module = require("./innerModule");
    var module2 = require("../outerModule");
    var module3 = require("packageName");
  
    // innerModule.js
    exports.myFunction = function() {}
  
    // outerModule.js
    module.exports = function() {}
  
    // package/index.js
    module.exports = {}