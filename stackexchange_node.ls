root = modules ? this

#request = require 'request'
querystring = require 'querystring'
http_get = require 'http-request'
#$ = require 'jQuery'

rootURL = 'http://api.stackexchange.com/2.1/'

wrapSE = root.wrapSE = (path, defaults, postprocess) ->
  if not defaults?
    defaults = {}
  if not defaults.site?
    defaults.site = 'stackoverflow'
  if not postprocess?
    postprocess = (x) -> x
  return (properties, callback) ->
    for k,v of defaults
      if not properties[k]?
        properties[k] = v
    console.log rootURL + path + '?' + querystring.stringify(properties)
    http_get.get(rootURL + path + '?' + querystring.stringify(properties), (err,data) -> callback(postprocess(data.buffer.toString())))

wrapSEJSON = root.wrapSEJSON = (path, defaults) -> wrapSE(path, defaults, JSON.parse)