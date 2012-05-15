var packageme = require("../../");

packageme(__dirname+"/issue-1/").toString(function(data){
  console.log(data);
});