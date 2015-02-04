// Generated by LiveScript 1.3.1
(function(){
  var root, wrapSEJSON, searchRaw, sortCompare, search;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  wrapSEJSON = require('./stackexchange_node').wrapSEJSON;
  searchRaw = wrapSEJSON('search/advanced', {
    'order': 'desc',
    'sort': 'relevance'
  });
  sortCompare = function(a, b){
    switch (false) {
    case !(a > b):
      return 1;
    case !(a < b):
      return -1;
    default:
      return 0;
    }
  };
  search = root.search = function(properties, callback){
    return searchRaw(properties, function(results){
      results.items.sort(function(a, b){
        return sortCompare(a.score, b.score);
      });
      results.items.reverse();
      return callback(results.items);
    });
  };
}).call(this);
