var siblingModule = require("./module");
var node_module = require("module");
module.exports = function() {
  return siblingModule.test()+"World"+node_module();
}