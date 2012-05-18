# Package.Me #

  * Command-line tool 
  * module 
  * express-like middleware 

for packaging of javascript, coffeescript & other^script code within a folder structure to

  * memory at runtime for development
  * file for production (TBD)

Inspired by nibjs, respecting CommonJS.

## usage as command-line tool ##

follwing will take sourceFolder/package.json and combine all supported scripts to destinationFile

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
    package({ sourceFolder: "path", format: "css" }).toString( ... )
    
    // will grab all html files from sourceFolders 
    // returns them 'escaped' with script tags for usage within browser like templates
    package({ sourceFolder: ["path1", "path2"], format: "html" }).toString( ... )

## usage as express middleware ##

    // will return sourceFolder packaged at URI /packages/packageName based on sourceFolder/package.json
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
    
## extra usage ##

packageme tries to get metadata per given source folder by reading 'package.json' or 'jspackage.json' file in its root,
which provides extra flexibility and control to the packaging process. 

Here is example package.json having only the fields which packageme reads:

    {
      "order": [
        "file1.js",
        "file2.js"
      ],
      "main": "myApp"
    } 
    
- `order` property forces packageme to place the files if found in the given order from beginning, and everything else after them.
- `main` property can be used to indicate a entry point of the compiled package which need to be required once the script is loaded.

    
## installation ##

For global usage install via `npm install packageme -g`, otherwise `npm install packageme` will do the work or include pacakgeme to you `package.json`

## Based on ##

  * nodejs
  * nibjs
  * coffeescript

## License ##

"packageme" is created by Boris Filipov. All rights not explicitly granted in the MIT license are reserved.

"Node.js" and "node" are trademarks owned by Joyent, Inc. 

"npm" and "the npm registry" are owned by Isaac Z. Schlueter.