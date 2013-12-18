root = exports ? this

wrapSEJSON = require('./stackexchange_node').wrapSEJSON

searchRaw = wrapSEJSON('search/advanced', {'order': 'desc', 'sort': 'relevance'})

sortCompare = (a,b) ->
  | a > b => 1
  | a < b => -1
  | otherwise => 0

search = root.search = (properties, callback) ->
  searchRaw properties, (results) ->
    results.items.sort (a,b) -> sortCompare a.score, b.score
    results.items.reverse()
    callback results.items

#search({'q': 'scipy'}, (output) ->
#  for item in output
#    console.log item.title
#)

#request('http://www.google.com', (err, res, body) ->
#  console.log body
#)

