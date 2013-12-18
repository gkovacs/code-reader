root = exports ? this

querystring = require 'querystring'
http_get = require 'http-request'

rootURL = 'http://glosbe.com/gapi/'

nstore = require 'nstore'
definitions_db = nstore.new 'dictionary-definitions.nstore'
examples_db = nstore.new 'dictionary-examples.nstore'

wrapDIC = root.wrapDIC = (path, defaults, postprocess) ->
  if not defaults?
    defaults = {}
  if not postprocess?
    postprocess = (x) -> x
  return (properties, callback) ->
    for k,v of defaults
      if not properties[k]?
        properties[k] = v
    console.log rootURL + path + '?' + querystring.stringify(properties)
    http_get.get(rootURL + path + '?' + querystring.stringify(properties), (err, data) -> callback(postprocess(data.buffer.toString())))

wrapDICJSON = root.wrapDICJSON = (path, defaults) -> wrapDIC(path, defaults, JSON.parse)

makeCaseAgnostic = (fn) ->
  return (properties, callback) ->
    fn properties, (output) ->
      if (typeof output == typeof [] and output.length > 0) or (typeof output == typeof 0 and output > 0) or not properties.phrase? or not properties.phrase.toLowerCase? or properties.phrase == properties.phrase.toLowerCase()
        callback output
      else
        np = {[k,v] for k,v of properties}
        np.phrase = np.phrase.toLowerCase()
        fn np, callback

#makeCaseAgnostic = (fn) -> fn

getDefinitionsRawUncached = root.getDefinitionsRawUncached = wrapDICJSON('translate', {'format': 'json', 'pretty': 'true', 'dest': 'en'})

getDefinitionsRaw = root.getDefinitionsRaw = (properties, callback) ->
  key = JSON.stringify(properties)
  console.log 'getDefinitionsRaw ' + key
  definitions_db.get key, (err, val) ->
    if val? and not properties.skipcache?
      callback JSON.parse(val)
    else
      console.log 'getDefinitionsRawUncached ' + key
      getDefinitionsRawUncached properties, (defs) ->
        definitions_db.save key, JSON.stringify(defs), ->
        callback defs

getDefinitionsCased = root.getDefinitionsCased = (properties, callback) ->
  getDefinitionsRaw properties, (output) ->
    defs = []
    defSet = {}
    for x in output.tuc
      if x.phrase? and x.phrase.text?
        if not defSet[x.phrase.text]?
          defs.push x.phrase.text
          defSet[x.phrase.text] = true
      if x.meanings?
        for meaning in x.meanings
          if not defSet[meaning.text]?
            defs.push meaning.text
            defSet[meaning.text] = true
    callback defs

getDefinitions = root.getDefinitions = makeCaseAgnostic getDefinitionsCased

getExamplesRawUncached = root.getExamplesRawUncached = wrapDICJSON('tm', {'format': 'json', 'pretty': 'true', 'dest': 'en'})

getExamplesRaw = root.getExamplesRaw = (properties, callback) ->
  key = JSON.stringify(properties)
  console.log 'getExamplesRaw ' + key
  examples_db.get key, (err, val) ->
    if val? and not properties.skipcache?
      callback JSON.parse(val)
    else
      console.log 'getExamplesRawUncached ' + key
      getExamplesRawUncached properties, (examples) ->
        examples_db.save key, JSON.stringify(examples), ->
        callback examples

getExamplesCased = root.getExamplesCased = (properties, callback) ->
  getExamplesRaw properties, (output) ->
    examples = []
    for x in output.examples
      examples.push x.first
    callback examples

getExamples = root.getExamples = makeCaseAgnostic getExamplesCased

getWordFreqCased = root.getWordFreqCased = (properties, callback) ->
  getExamplesRaw properties, (output) ->
    callback output.found

getWordFreq = root.getWordFreq = makeCaseAgnostic getWordFreqCased

main = ->
  #getDefinitions({'phrase': 'super', 'from': 'en'}, (output) -> console.log output)
  #getExamples({'phrase': 'fungible', 'from': 'en'}, (output) -> console.log output)
  getWordFreq({'phrase': 'sequestration', 'from': 'en'}, (output) -> console.log output)

main() if require.main is module