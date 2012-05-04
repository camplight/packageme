function Route(path, callback) {
  var match;
  this.path = path;
  this.callback = callback;
  this.names = [];
  if (typeof path === 'string') {
    namedParam.lastIndex = 0;
    while ((match = namedParam.exec(path)) !== null) {
      this.names.push(match[1]);
    }
    path = path.replace(escapeRegExp, '\\$&').replace(namedParam, '([^\/]*)').replace(splatParam, '(.*?)');
    this.route = new RegExp('^' + path + '$');
  } else {
    this.route = path;
  }
}