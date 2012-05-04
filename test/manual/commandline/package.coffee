#!/usr/bin/env coffee
{exec} = require 'child_process'

exec 'packageme '+__dirname+"/../sample-package-data "+__dirname+"/output.js", (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr