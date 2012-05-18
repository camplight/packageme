(function(){
  var require = function(path, useCache){
    return %context%.packageme.require(path, useCache, require.path);
  };
  var requireFolder = function(path) {
    return %context%.packageme.requireFolder(path, require.path);
  }
  require.path = "%path%";
  var exports = {};
  var module = {exports: exports};
  %context%.packageme.register("%path%%name%", function(){
    %code%
    return module.exports;
  });
})();