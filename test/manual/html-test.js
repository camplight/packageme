var packageme = require("../../");

packageme({sourceFolder: __dirname+"/sample-package-data/views/", format: "html"}).toString(function(data){
  console.log(data);
});