root = exports ? this

express = require 'express'
request = require 'request'
app = express()

dictionary = require './dictionary'
js_parser = require './js_parser'
github = require './github'
stackoverflow = require './stackoverflow'

app.configure ->
  app.use(express.static(__dirname + '/static'))

http = require 'http'
httpserver = http.createServer(app)
httpserver.listen(3456)

app.get '/searchStackOverflow', (req, res) ->
  params = {[k,v] for k,v of req.query}
  stackoverflow.search(params, (x) -> x |> JSON.stringify |> res.send)

app.get '/searchCode', (req, res) ->
  params = {[k,v] for k,v of req.query}
  console.log params
  github.searchCode(params.searchTerm, params.lang, (x) -> x |> JSON.stringify |> res.send)

app.get '/getRepositories', (req, res) ->
  params = {[k,v] for k,v of req.query}
  params.numPages ?= 10
  params.numPages = parseInt(params.numPages)
  github.getRepositories(params.lang, params.numPages, (x) -> x |> JSON.stringify |> res.send)

app.get '/getCallExpressions', (req, res) ->
  params = {[k,v] for k,v of req.query}
  res.send JSON.stringify(js_parser.getCallExpressions(params.phrase))

app.get '/getWordFreq', (req, res) ->
  #request('http://localhost:5000' + req.url).pipe(res)
  #res.redirect(301, 'http://localhost:5000' + req.url)
  params = {[k,v] for k,v of req.query}
  if not params.from?
    params.from = 'en'
  if not params.dest?
    params.dest = 'en'
  dictionary.getWordFreq(params, (output) -> res.send output.toString())

app.get '/getDefinitionsRaw', (req, res) ->
  params = {[k,v] for k,v of req.query}
  if not params.from?
    params.from = 'en'
  if not params.dest?
    params.dest = 'en'
  dictionary.getDefinitionsRaw(params, (output) -> res.send output)

app.get '/getDefinitions', (req, res) ->
  params = {[k,v] for k,v of req.query}
  if not params.from?
    params.from = 'en'
  if not params.dest?
    params.dest = 'en'
  dictionary.getDefinitions(params, (output) -> res.send output)

app.get '/getExamplesRaw', (req, res) ->
  params = {[k,v] for k,v of req.query}
  if not params.from?
    params.from = 'en'
  if not params.dest?
    params.dest = 'en'
  dictionary.getExamplesRaw(params, (output) -> res.send output)

app.get '/getExamples', (req, res) ->
  params = {[k,v] for k,v of req.query}
  if not params.from?
    params.from = 'en'
  if not params.dest?
    params.dest = 'en'
  dictionary.getExamples(params, (output) -> res.send output)

