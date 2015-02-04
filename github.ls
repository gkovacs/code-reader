root = exports ? this

querystring = require 'querystring'
http_get = require 'http-request'

async = require 'async'

nstore = require 'nstore'

repositories_db = nstore.new 'github_repositories.nstore'
codesearch_db = nstore.new 'github_codesearch.nstore'

rootURL = 'https://api.github.com'

fs = require 'fs'

if process.env.GITHUB_CLIENT_ID? and process.end.GITHUB_CLIENT_SECRET?
  client_id = process.env.GITHUB_CLIENT_ID
  client_secret = process.env.GITHUB_CLIENT_SECRET
else
  {client_id,client_secret} = JSON.parse fs.readFileSync('github_client_secret.json', 'utf-8')

wrapGH = (path, defaults, postprocess) ->
  defaults ?= {}
  postprocess ?= (x) -> x
  defaults.client_id ?= client_id
  defaults.client_secret ?= client_secret
  return (properties, callback) ->
    for k,v of defaults
      if not properties[k]?
        properties[k] = v
    headers = properties.headers
    if not headers?
      headers = {}
    console.log rootURL + path + '?' + querystring.stringify(properties)
    http_get.get {
      url: rootURL + path + '?' + querystring.stringify(properties),
      headers: headers
    }, (err, data) -> data.buffer.toString() |> postprocess |> callback 

wrapGHJSON = root.wrapGHJSON = (path, defaults) -> wrapGH path, defaults, JSON.parse

getRepositoriesRawUncached = root.getRepositoriesRawUncached = wrapGHJSON '/search/repositories', {sort: 'stars', order: 'desc', per_page: 100}

getRepositoriesRaw = root.getRepositoriesRaw = (properties, callback) ->
  key = JSON.stringify properties
  console.log 'getRepositoriesRaw ' + key
  repositories_db.get key, (err, val) ->
    if val? and not properties.skipcache?
      callback JSON.parse(val)
    else
      console.log 'getRepositoriesRawUncached ' + key
      getRepositoriesRawUncached properties, (results) ->
        repositories_db.save key, JSON.stringify(results), ->
        callback results

errWrap = (f) -> (...args, callback) -> f args, (results) -> callback null, results

getRepositories = root.getRepositories = (lang, numPages, callback) ->
  getPage = (pageNum, callback) -> getRepositoriesRaw {q: 'language:' + lang, page: pageNum}, (results) -> callback null, results
  async.map [1 to numPages], getPage, (errs, results) ->
    output = []
    for page_results in results
      for item in page_results.items
        output.push item.full_name
    callback output

searchCodeRawUncached = root.searchCodeRawUncached = wrapGHJSON '/search/code', {order: 'desc', per_page: 100, headers: {Accept: 'application/vnd.github.v3.text-match+json'}}

searchCodeRaw = root.searchCodeRaw = (properties, callback) ->
  key = JSON.stringify properties
  console.log 'searchCodeRaw ' + key
  codesearch_db.get key, (err, val) ->
    if val? and not properties.skipcache?
      callback JSON.parse(val)
    else
      console.log 'searchCodeRawUncached ' + key
      searchCodeRawUncached properties, (results) ->
        codesearch_db.save key, JSON.stringify(results), ->
        callback results

sortCompare = (a,b) ->
  | a > b => 1
  | a < b => -1
  | otherwise => 0

searchCode = root.searchCode = (searchTerm, lang, callback) ->
  getRepositories lang, 1, (allrepos) ->
    reposBy20 = [allrepos[20*i til 20*(i+1)] for i in [0 til Math.floor(allrepos.length / 20)]]
    #console.log [reposBy20[0]]
    #return
    searchInRepos = (repos, callback) ->
      reposText = ['repo:'+x for x in repos].join ' '
      searchCodeRaw {
        q: searchTerm + ' in:file language:' + lang + ' ' + reposText
      }, (results) -> callback(null, results)
    async.map reposBy20, searchInRepos, (errs, results) ->
      output = []
      for repogroup_results in results
        for item in repogroup_results.items
          output.push item
      output.sort (a,b) -> sortCompare a.score, b.score
      output.reverse()
      callback output

main = ->
  #getRepositories 'javascript', 10, (data) -> console.log data
  searchCode 'sort', 'javascript', (data) -> console.log [x.text_matches for x in data]

main() if require.main is module
