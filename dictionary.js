// Generated by LiveScript 1.3.1
(function(){
  var root, querystring, http_get, rootURL, nstore, definitions_db, examples_db, wrapDIC, wrapDICJSON, makeCaseAgnostic, getDefinitionsRawUncached, getDefinitionsRaw, getDefinitionsCased, getDefinitions, getExamplesRawUncached, getExamplesRaw, getExamplesCased, getExamples, getWordFreqCased, getWordFreq, main;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  querystring = require('querystring');
  http_get = require('http-request');
  rootURL = 'http://glosbe.com/gapi/';
  nstore = require('nstore');
  definitions_db = nstore['new']('dictionary-definitions.nstore');
  examples_db = nstore['new']('dictionary-examples.nstore');
  wrapDIC = root.wrapDIC = function(path, defaults, postprocess){
    if (defaults == null) {
      defaults = {};
    }
    if (postprocess == null) {
      postprocess = function(x){
        return x;
      };
    }
    return function(properties, callback){
      var k, ref$, v;
      for (k in ref$ = defaults) {
        v = ref$[k];
        if (properties[k] == null) {
          properties[k] = v;
        }
      }
      console.log(rootURL + path + '?' + querystring.stringify(properties));
      return http_get.get(rootURL + path + '?' + querystring.stringify(properties), function(err, data){
        return callback(postprocess(data.buffer.toString()));
      });
    };
  };
  wrapDICJSON = root.wrapDICJSON = function(path, defaults){
    return wrapDIC(path, defaults, JSON.parse);
  };
  makeCaseAgnostic = function(fn){
    return function(properties, callback){
      return fn(properties, function(output){
        var np, res$, k, ref$, v;
        if ((typeof output === typeof [] && output.length > 0) || (typeof output === typeof 0 && output > 0) || properties.phrase == null || properties.phrase.toLowerCase == null || properties.phrase === properties.phrase.toLowerCase()) {
          return callback(output);
        } else {
          res$ = {};
          for (k in ref$ = properties) {
            v = ref$[k];
            res$[k] = v;
          }
          np = res$;
          np.phrase = np.phrase.toLowerCase();
          return fn(np, callback);
        }
      });
    };
  };
  getDefinitionsRawUncached = root.getDefinitionsRawUncached = wrapDICJSON('translate', {
    'format': 'json',
    'pretty': 'true',
    'dest': 'en'
  });
  getDefinitionsRaw = root.getDefinitionsRaw = function(properties, callback){
    var key;
    key = JSON.stringify(properties);
    console.log('getDefinitionsRaw ' + key);
    return definitions_db.get(key, function(err, val){
      if (val != null && properties.skipcache == null) {
        return callback(JSON.parse(val));
      } else {
        console.log('getDefinitionsRawUncached ' + key);
        return getDefinitionsRawUncached(properties, function(defs){
          definitions_db.save(key, JSON.stringify(defs), function(){});
          return callback(defs);
        });
      }
    });
  };
  getDefinitionsCased = root.getDefinitionsCased = function(properties, callback){
    return getDefinitionsRaw(properties, function(output){
      var defs, defSet, i$, ref$, len$, x, j$, ref1$, len1$, meaning;
      defs = [];
      defSet = {};
      for (i$ = 0, len$ = (ref$ = output.tuc).length; i$ < len$; ++i$) {
        x = ref$[i$];
        if (x.phrase != null && x.phrase.text != null) {
          if (defSet[x.phrase.text] == null) {
            defs.push(x.phrase.text);
            defSet[x.phrase.text] = true;
          }
        }
        if (x.meanings != null) {
          for (j$ = 0, len1$ = (ref1$ = x.meanings).length; j$ < len1$; ++j$) {
            meaning = ref1$[j$];
            if (defSet[meaning.text] == null) {
              defs.push(meaning.text);
              defSet[meaning.text] = true;
            }
          }
        }
      }
      return callback(defs);
    });
  };
  getDefinitions = root.getDefinitions = makeCaseAgnostic(getDefinitionsCased);
  getExamplesRawUncached = root.getExamplesRawUncached = wrapDICJSON('tm', {
    'format': 'json',
    'pretty': 'true',
    'dest': 'en'
  });
  getExamplesRaw = root.getExamplesRaw = function(properties, callback){
    var key;
    key = JSON.stringify(properties);
    console.log('getExamplesRaw ' + key);
    return examples_db.get(key, function(err, val){
      if (val != null && properties.skipcache == null) {
        return callback(JSON.parse(val));
      } else {
        console.log('getExamplesRawUncached ' + key);
        return getExamplesRawUncached(properties, function(examples){
          examples_db.save(key, JSON.stringify(examples), function(){});
          return callback(examples);
        });
      }
    });
  };
  getExamplesCased = root.getExamplesCased = function(properties, callback){
    return getExamplesRaw(properties, function(output){
      var examples, i$, ref$, len$, x;
      examples = [];
      for (i$ = 0, len$ = (ref$ = output.examples).length; i$ < len$; ++i$) {
        x = ref$[i$];
        examples.push(x.first);
      }
      return callback(examples);
    });
  };
  getExamples = root.getExamples = makeCaseAgnostic(getExamplesCased);
  getWordFreqCased = root.getWordFreqCased = function(properties, callback){
    return getExamplesRaw(properties, function(output){
      return callback(output.found);
    });
  };
  getWordFreq = root.getWordFreq = makeCaseAgnostic(getWordFreqCased);
  main = function(){
    return getWordFreq({
      'phrase': 'sequestration',
      'from': 'en'
    }, function(output){
      return console.log(output);
    });
  };
  if (require.main === module) {
    main();
  }
}).call(this);
