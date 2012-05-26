var packageme = require("../../");

packageme({source: __dirname+"/issue-1/", useCache: true}).toString(function(data){
  console.log(data);
});