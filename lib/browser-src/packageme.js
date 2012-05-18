(function(context){
  context.packageme = {
    modules: [],
    cache: [],
    register: function(modulePath, moduleBuilder) {
      this.modules[modulePath] = moduleBuilder;
      this.modules[modulePath].path = modulePath;
    },
    requireFolder: function(path, startPoint) {
      if(!startPoint)
        startPoint = "/";
      
      if(path.indexOf("./") == 0 || path.indexOf("../") == 0)
        path = startPoint+path
      path = this.normalizePath(path);

      var result = {};
      var namespace = function(p) {
        var current = result;
        var parts = p.split("/");
        for(var i = 0; i<parts.length-1; i++) {
          if(typeof result[parts[i]] == "undefined")
            current[parts[i]] = {};
          current = current[parts[i]];
        }
        return current;
      }
      
      for(var name in this.modules) {

        if(name.indexOf(path) == 0) {
          var innerPath = name.replace(path+"/", "");
          var n = namespace(innerPath);
          var moduleName = innerPath.substring(innerPath.lastIndexOf("/")+1);
          
          n[moduleName] = this.require(name);
        }
      }
      return result;
    },
    require: function(modulePath, useCache, startPoint) {
      if(useCache == undefined)
        useCache = true;
      if(!startPoint)
        startPoint = "/";
      
      // build full path to the required Module based on starterPoint
      if(modulePath.indexOf("./") == 0 || modulePath.indexOf("../") == 0)
        modulePath = startPoint+modulePath;
     
      // normalize full path
      modulePath = this.normalizePath(modulePath);
      
      // try getting module at given path
      var moduleBuilder = this.modules[modulePath] || 
                          this.modules[modulePath+"/index"] || 
                          this.modules[startPoint+"node_modules/"+modulePath] || 
                          this.modules[startPoint+"node_modules/"+modulePath+"/index"] || 
                          this.modules["/node_modules/"+modulePath];

      if(moduleBuilder) {
        if(!this.cache[moduleBuilder.path] && useCache)
          this.cache[moduleBuilder.path] = moduleBuilder();
        return this.cache[moduleBuilder.path];
      }
      else
        throw new Error("module at path '"+modulePath+"' was not found");
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
})(%context%);