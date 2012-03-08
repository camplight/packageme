(function(){
  var require = function(path){
    return packageme.require(path, require.path);
  };
  require.path = "%path%";
  var exports = {};
  var module = {exports: exports};
  packageme.register("%path%%name%", function(){
    %code%
    return module.exports;
  });
})();