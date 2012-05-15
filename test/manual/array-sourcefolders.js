var packageme = require("../../");

packageme([__dirname+"/sample-package-data", __dirname+"/issue-1"]).toString(function(data){
  console.log(data);
});