(function(context){
  context.packageme = {
    modules: [],
    register: function(modulePath, moduleBuilder) {
      this.modules[modulePath] = moduleBuilder();
    },
    require: function(modulePath, startPoint) {
      
      // build full path to the required Module based on starterPoint
      if(modulePath.indexOf("./") == 0 || modulePath.indexOf("../") == 0)
        modulePath = startPoint+modulePath;
      // normalize full path
      modulePath = this.normalizePath(modulePath);

      // try getting module at given path
      return this.modules[modulePath] || 
        this.modules[modulePath+"/index"] || 
        this.modules[startPoint+"/node_modules/"+modulePath] || 
        this.modules["/node_modules/"+modulePath];
    },
    normalizePath: function(path) {
      var isAbsolute = path.charAt(0) === '/',
        trailingSlash = path.slice(-1) === '/';

      // Normalize the path
      path = this.normalizeArray(path.split('/').filter(function(p) {
        return !!p;
      }), !isAbsolute).join('/');

      if (!path && !isAbsolute) {
        path = '.';
      }
      if (path && trailingSlash) {
        path += '/';
      }

      return (isAbsolute ? '/' : '') + path;
    },
    normalizeArray: function(parts, allowAboveRoot) {
      // if the path tries to go above the root, `up` ends up > 0
      var up = 0;
      for (var i = parts.length - 1; i >= 0; i--) {
        var last = parts[i];
        if (last == '.') {
          parts.splice(i, 1);
        } else if (last === '..') {
          parts.splice(i, 1);
          up++;
        } else if (up) {
          parts.splice(i, 1);
          up--;
        }
      }

      // if the path is allowed to go above the root, restore leading ..s
      if (allowAboveRoot) {
        for (; up--; up) {
          parts.unshift('..');
        }
      }

      return parts;
    }
  }
})(window);
(function(){
  var require = function(path){
    return packageme.require(path, require.path);
  };
  require.path = "test/sample-package-data";
  var exports = null;
  var module = {exports: exports};
  packageme.register("test/sample-package-data/index", function(){
    var module = require("./module");
    var node_module = require("module");
    module.exports = function() {
      return module.test()+"World"+node_module();
    }
    return module.exports;
  });
})();
(function(){
  var require = function(path){
    return packageme.require(path, require.path);
  };
  require.path = "test/sample-package-data/node_modules/module";
  var exports = null;
  var module = {exports: exports};
  packageme.register("test/sample-package-data/node_modules/module/main", function(){
    
    module.exports = function() {
      var m = require("fancyModule");
      return "main"+m();
    }
    return module.exports;
  });
})();
(function(){
  var require = function(path){
    return packageme.require(path, require.path);
  };
  require.path = "test/sample-package-data/node_modules/module/node_modules/fancyModule";
  var exports = null;
  var module = {exports: exports};
  packageme.register("test/sample-package-data/node_modules/module/node_modules/fancyModule/fancyModule", function(){
    module.exports = function(){
      return "fancyModule";
    }
    return module.exports;
  });
})();

(function() {
  var exports, module, require;

  require = function(path) {
    return packageme.require(path, require.path);
  };

  require.path = "test/sample-package-data/module";

  exports = null;

  module = {
    exports: exports
  };

  packageme.register("test/sample-package-data/module/index", function() {
    exports.test = function() {
      return "Hello";
    };
    return module.exports;
  });

}).call(this);

