var packageme = require("../../");

packageme({sourceFolder: __dirname+"/sample-package-data/", format: "css"}).toString(function(data){
  console.log(data);
});