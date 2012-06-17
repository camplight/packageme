# Package.Me #

  * Command-line tool 
  * module 
  * express-like middleware 

for packaging of javascript, coffeescript & other^script code within a folder structure to

  * memory
  * file

Inspired by nibjs, respecting CommonJS.

## usage as command-line tool ##

    packageme sourceFolder destinationFile

## usage as nodejs module ##

    var package = require("packageme");
  
    // will write sourceFolder to destinationFile, invoking resultHandler on end
    package(sourceFolder).toFile(destinationFile, function(data){ }); 
  
    // will write sourceFolder to string, invoking resultHandler(string) on end
    package(sourceFolder).toString(function(data){ });
  
    // will pipe the sourceFolder to string, will invoke stream.end() once finished.
    package(sourceFolder).pipe(stream);
    
    // will combine both folders to string
    package([sourceFolder1, sourceFolder2]).toString( ... )
    
    // will grab all the stylesheets from "path" and will return single string
    package({ source: "path", format: "css" }).toString( ... )
    
    // will grab all html files from sourceFolders 
    // returns them 'escaped' with script tags for usage within browser like templates
    package({ source: ["path1", "path2"], format: "html" }).toString( ... )

## usage as express middleware ##

    // will return express middleware for packaging javascripts/coffeescripts at specified URI
    app.configure(function(){
      app.use(package(...).toExpressMiddleware(URI));
      app.use(app.router);
    });

    // will return express route handler with given packageme options
    app.get("url", package(...).toExpressURIHandler());

## in browser usage ##

    // will return module instance of "moduleName"
    var library = packageme.require("moduleName");
  
    // will return module instance of moduleA from path 'packageName/libs/'
    var module = packageme.require("packageName/libs/moduleA");
  
    // require statements act as they should even within modules
    // requires respect the actual sever-side structure of the code, nevertheless they are emulated within the browser.
    var module = require("./innerModule");
    var module2 = require("../outerModule");
    var module3 = require("packageName");
    
    // will require all found modules in given folder and return them as object using inner directories as namespaces
    var models = requireFolder("../models");
    // new models.User() refers to models/User.js
    // new models.inner.Session refers to models/inner/Session.js
  
    // innerModule.js
    exports.myFunction = function() {}
  
    // outerModule.js
    module.exports = function() {}
  
    // packageName/index.js
    module.exports = {}
    
    // models/User.js
    module.exports = function() {}
    module.exports.prototype = {}
    
    // models/inner/Session.js
    module.exports = function() {}
    
## Reference ##
### client-side packageme ###

- `packageme.require( modulePath, useCache, startPoint )` 
  - useCache - optional
  - startPoint - optional
- `packageme.requireFolder( modulePath, startPoint )`
  - startPoint - optional

### server-side packageme ###
- `packageme( options or String or Array )`
  - `options.format` -> defaults to `"js"`, can be "html", "coffee", "css", indicates the formatter/render to be used
  - `options.render` -> defaults to `packageme`, can be "snockets", if set uses ["snockets"](https://github.com/TrevorBurnham/snockets) to combine, package and stream javascript/coffeescript code
  - `options.source` -> can be single `path String` or `Array of path Strings` pointing to files and/or folders to be packaged.
    Or can be an `File` object which need to have the following properties set:
      - `fullPath` - from where to read
      - `relativePath` - where to be placed within browser
      - `name` - name of the module
      - `extension`

  - `options.context` -> defaults to `window` string, indicates to which context name packageme should register itself and its results.
  - `options.useCache` -> defaults to `undefined`, can be `true` or `false`, indicates that packageme should combine, compile and package given `options.source` only once. Cache uses in-memory store. Enable this on production instances.
  - `options.compile` -> defaults to `undefined`, can be `true` or `false`, indicates that packageme should combine, compile and package given `options.source`. Useful when getting script/style tags and serving those files via express
- `toString(function(data){})`
- `toFile(destinationFile, function(){})`
- `toExpressURIHandler()`
- `toExpressMiddleware(URI)`
- `toScriptTags()`
- `toStyleTags()`
- `serveFilesToExpress(app)`
- `pipe(stream)`

    
## installation ##

For global usage install via `npm install packageme -g`, otherwise `npm install packageme` will do the work or include pacakgeme to you `package.json`

## Based on ##

  * nodejs
  * nibjs
  * coffeescript
  * snockets

## License ##

"packageme" is created by Boris Filipov. All rights not explicitly granted in the MIT license are reserved.

"Node.js" and "node" are trademarks owned by Joyent, Inc. 

"npm" and "the npm registry" are owned by Isaac Z. Schlueter.