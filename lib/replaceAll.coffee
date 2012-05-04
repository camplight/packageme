module.exports = (pattern, target, replacement) ->
  target.replace(new RegExp(pattern.replace(/([\/\,\!\\\^\$\{\}\[\]\(\)\.\*\+\?\|\<\>\-\&])/g,"\\$&"),"g"),replacement.replace(/\$/g,"$$$$"))