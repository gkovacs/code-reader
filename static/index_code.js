// Generated by LiveScript 1.3.1
(function(){
  var root, textBody, getWordFreq, getDefinitions, getExamples, toText, generateWordBox, expandWord, highlightInSource, wordClicked, tokenize, getUrlParameters, getCallExpressions, sortCompare, githubSearchCodeAsync, stackoverflowSearchAsync, setTextWithNewlines, slice$ = [].slice;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  textBody = root.textBody = 'function qsort(array, begin, end)\n{\n  if(end-1>begin) {\n    var pivot=begin+Math.floor(Math.random()*(end-begin));\n\n    pivot=partition(array, begin, end, pivot);\n\n    qsort(array, begin, pivot);\n    qsort(array, pivot+1, end);\n  }\n}';
  root.fromLang = 'javascript';
  root.destLang = 'en';
  root.wordToFrequency = {};
  root.wordToInfo = {};
  root.wordsSortedByFreq = [];
  root.wordToSourceIndexes = {};
  getWordFreq = root.getWordFreq = function(word, callback){
    return $.get('/getWordFreq?' + $.param({
      'phrase': word,
      'from': root.fromLang,
      'dest': root.destLang
    }), function(data){
      return callback(null, parseInt(data));
    });
  };
  getDefinitions = root.getDefinitions = function(word, callback){
    return $.get('/getDefinitions?' + $.param({
      'phrase': word,
      'from': root.fromLang,
      'dest': root.destLang
    }), function(data){
      return callback(null, data);
    });
  };
  getExamples = root.getExamples = function(word, callback){
    return $.get('/getExamples?' + $.param({
      'phrase': word,
      'from': root.fromLang,
      'dest': root.destLang
    }), function(data){
      return callback(null, data);
    });
  };
  toText = function(html){
    return $('<span>').html(html).text();
  };
  generateWordBox = function(word, definitions, examples){
    var wordDiv, definitionDiv, x, exampleDiv, childDiv;
    wordDiv = $('<h3>').html(word).css('background-color', 'blue');
    definitionDiv = $('<div>').text((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = [definitions[0], definitions[1], definitions[2]]).length; i$ < len$; ++i$) {
        x = ref$[i$];
        results$.push(toText(x));
      }
      return results$;
    }()).join('; ')).css('font-style', 'normal');
    exampleDiv = $('<div>').text(toText(examples[0])).css('font-style', 'italic');
    childDiv = $('<div>').append(definitionDiv).append(exampleDiv);
    return childDiv.html();
  };
  expandWord = root.expandWord = function(word){
    var wordIdx, topOffset;
    wordIdx = root.wordsSortedByFreq.indexOf(word);
    if (wordIdx >= 0) {
      $('#explanationDisplay').accordion('option', 'active', wordIdx);
      topOffset = $('#HEADER' + word).offset().top;
      console.log('topOffset is:' + topOffset);
      return $('#rightFrame').animate({
        'scrollTop': topOffset + $('#rightFrame').scrollTop()
      });
    }
  };
  highlightInSource = root.highlightInSource = function(word){
    var i$, ref$, len$, x, results$ = [];
    for (i$ = 0, len$ = (ref$ = $('.highlighted')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      console.log(x);
      $(x).removeClass('highlighted');
      if ($(x).attr('ismethod') === 'true') {
        $(x).addClass('bluehighlight');
      }
    }
    for (i$ = 0, len$ = (ref$ = $('.SOURCE' + word.split('.').join('-'))).length; i$ < len$; ++i$) {
      x = ref$[i$];
      $(x).removeClass('bluehighlight');
      results$.push($(x).addClass('highlighted'));
    }
    return results$;
  };
  wordClicked = root.wordClicked = function(word){
    highlightInSource(word);
    return expandWord(word);
  };
  tokenize = root.tokenize = function(text, delimiterList){
    var tokenList, currentToken, i$, len$, c;
    tokenList = [];
    currentToken = [];
    for (i$ = 0, len$ = text.length; i$ < len$; ++i$) {
      c = text[i$];
      if (delimiterList.indexOf(c) === -1) {
        currentToken.push(c);
      } else {
        if (currentToken.length > 0) {
          tokenList.push(currentToken.join(''));
        }
        tokenList.push(c);
        currentToken = [];
      }
    }
    if (currentToken.length > 0) {
      tokenList.push(currentToken.join(''));
      currentToken = [];
    }
    return tokenList;
  };
  getUrlParameters = root.getUrlParameters = function(){
    var map, parts;
    map = {};
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value){
      return map[key] = decodeURI(value);
    });
    return map;
  };
  getCallExpressions = function(programText, callback){
    return $.get('/getCallExpressions?' + $.param({
      phrase: programText
    }), function(data){
      return callback(
      JSON.parse(
      data));
    });
  };
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
  githubSearchCodeAsync = function(searchTerm, callback){
    return $.get('/searchCode?' + $.param({
      searchTerm: searchTerm,
      lang: 'javascript'
    }), function(results){
      return callback(null, JSON.parse(results));
    });
  };
  stackoverflowSearchAsync = function(searchTerm, callback){
    return $.get('/searchStackOverflow?' + $.param({
      q: searchTerm
    }), function(results){
      return callback(null, JSON.parse(results));
    });
  };
  setTextWithNewlines = function(elem, text){
    var i$, len$, x;
    for (i$ = 0, len$ = elem.length; i$ < len$; ++i$) {
      x = elem[i$];
      x.innerText = text;
    }
    return elem;
  };
  $(document).ready(function(){
    var urlParams;
    urlParams = getUrlParameters();
    if (urlParams.from != null) {
      root.fromLang = urlParams.from;
    }
    if (urlParams.dest != null) {
      root.destLang = urlParams.dest;
    }
    if (urlParams.text != null && root.textBody == null) {
      root.textBody = unescape(urlParams.text);
    }
    return getCallExpressions(root.textBody, function(callExpressions){
      var spanStartIdx, i$, len$, ref$, start, end, text;
      callExpressions.sort(function(a, b){
        return sortCompare(a.start, b.start);
      });
      spanStartIdx = 0;
      for (i$ = 0, len$ = callExpressions.length; i$ < len$; ++i$) {
        ref$ = callExpressions[i$], start = ref$.start, end = ref$.end, text = ref$.text;
        if (start > spanStartIdx) {
          $('#codeDisplay').append(setTextWithNewlines($('<span>'), slice$.call(root.textBody, spanStartIdx, start).join('')).addClass('code'));
        }
        $('#codeDisplay').append(setTextWithNewlines($('<span>'), text).addClass('SOURCE' + text.split('.').join('-')).addClass('bluehighlight').attr('ismethod', 'true').attr('methodname', text).attr('onclick', 'wordClicked("' + text + '")').addClass('code'));
        spanStartIdx = end;
        console.log(text);
      }
      if (spanStartIdx < root.textBody.length) {
        $('#codeDisplay').append(setTextWithNewlines($('<span>'), slice$.call(root.textBody, spanStartIdx).join('')).addClass('code'));
      }
      root.wordsSortedByFreq = _.uniq((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = callExpressions).length; i$ < len$; ++i$) {
          text = ref$[i$].text;
          results$.push(text);
        }
        return results$;
      }()));
      return async.map(root.wordsSortedByFreq, githubSearchCodeAsync, function(err0, githubSearchResults){
        root.githubSearchResults = githubSearchResults;
        return async.map(root.wordsSortedByFreq, stackoverflowSearchAsync, function(err1, stackoverflowSearchResults){
          var i$, ref$, len$, ref1$, text, githubResults, stackoverflowResults, expdiv, j$, len1$, sores, ghres, delimiters, tokens, words, word, idx, token;
          root.stackoverflowSearchResults = stackoverflowSearchResults;
          for (i$ = 0, len$ = (ref$ = _.zip(root.wordsSortedByFreq, root.githubSearchResults, root.stackoverflowSearchResults)).length; i$ < len$; ++i$) {
            ref1$ = ref$[i$], text = ref1$[0], githubResults = ref1$[1], stackoverflowResults = ref1$[2];
            $('#explanationDisplay').append($('<h3>').html(text).attr('id', 'HEADER' + text.split('.').join('-')));
            expdiv = $('<div>');
            expdiv.append($('<a>').text('StackOverflow:').attr('href', 'https://stackoverflow.com/search?q=' + text).attr('target', '_blank').css('color', 'blue'));
            expdiv.append($('<br>'));
            for (j$ = 0, len1$ = (ref1$ = [stackoverflowResults[0], stackoverflowResults[1], stackoverflowResults[2]]).length; j$ < len1$; ++j$) {
              sores = ref1$[j$];
              expdiv.append($('<br>'));
              expdiv.append($('<a>').html(sores.title).attr('href', sores.link).attr('target', '_blank'));
              console.log(sores);
            }
            expdiv.append($('<br>'));
            expdiv.append($('<br>'));
            expdiv.append($('<a>').text('Github:').attr('href', 'https://github.com/search?type=Code&q=' + text).attr('target', '_blank').css('color', 'blue'));
            expdiv.append($('<br>'));
            for (j$ = 0, len1$ = (ref1$ = [githubResults[0], githubResults[1], githubResults[2]]).length; j$ < len1$; ++j$) {
              ghres = ref1$[j$];
              expdiv.append($('<br>'));
              expdiv.append($('<a>').text(ghres.path).attr('href', ghres.html_url).attr('target', '_blank'));
              expdiv.append($('<br>'));
              expdiv.append(setTextWithNewlines($('<span>'), ghres.text_matches[0].fragment).addClass('code'));
              expdiv.append($('<br>'));
              console.log(ghres);
            }
            $('#explanationDisplay').append(expdiv);
          }
          $('#explanationDisplay').accordion({
            'heightStyle': 'content',
            'collapsible': true,
            'active': false,
            'animate': false,
            'activate': function(event, ui){
              return highlightInSource(ui.newHeader.text().split('.').join('-'));
            }
          });
          return;
          delimiters = [' ', ',', '.', ':'];
          tokens = tokenize(root.textBody, delimiters);
          words = [];
          for (i$ = 0, len$ = tokens.length; i$ < len$; ++i$) {
            word = tokens[i$];
            if (delimiters.indexOf(word) === -1) {
              words.push(word);
            }
          }
          console.log(words);
          for (i$ = 0, len$ = (ref$ = tokenize(root.textBody, delimiters)).length; i$ < len$; ++i$) {
            idx = i$;
            token = ref$[i$];
            if (root.wordToSourceIndexes[token] == null) {
              root.wordToSourceIndexes[token] = [];
            }
            root.wordToSourceIndexes[token].push(idx);
            if (delimiters.indexOf(token) === -1) {
              $('#codeDisplay').append($('<span>').text(token).addClass('SOURCE' + token).attr('onclick', 'wordClicked("' + token + '")'));
            } else {
              $('#codeDisplay').append($('<span>').text(token));
            }
          }
          return async.mapSeries(words, getWordFreq, function(err0, freqResults){
            return async.mapSeries(words, getDefinitions, function(err1, definitionResults){
              return async.mapSeries(words, getExamples, function(err2, exampleResults){
                var i$, ref$, len$, ref1$, word, freq, definitions, examples, res$, isSorted;
                for (i$ = 0, len$ = (ref$ = _.zip(words, freqResults, definitionResults, exampleResults)).length; i$ < len$; ++i$) {
                  ref1$ = ref$[i$], word = ref1$[0], freq = ref1$[1], definitions = ref1$[2], examples = ref1$[3];
                  if (root.wordToFrequency[word] != null) {
                    continue;
                  }
                  root.wordToFrequency[word] = freq;
                  root.wordToInfo[word] = generateWordBox(word, definitions, examples);
                }
                res$ = [];
                for (i$ = 0, len$ = (ref$ = words).length; i$ < len$; ++i$) {
                  word = ref$[i$];
                  res$.push(word);
                }
                root.wordsSortedByFreq = res$;
                root.wordsSortedByFreq.sort(function(x, y){
                  return root.wordToFrequency[x] < root.wordToFrequency[y];
                });
                root.wordsSortedByFreq = _.uniq(wordsSortedByFreq, isSorted = true);
                root.wordsSortedByFreq.reverse();
                for (i$ = 0, len$ = (ref$ = root.wordsSortedByFreq).length; i$ < len$; ++i$) {
                  word = ref$[i$];
                  console.log(word);
                  $('#explanationDisplay').append($('<h3>').html(word).attr('id', 'HEADER' + word));
                  $('#explanationDisplay').append($('<div>').html(root.wordToInfo[word]));
                }
                return $('#explanationDisplay').accordion({
                  'heightStyle': 'content',
                  'collapsible': true,
                  'active': false,
                  'animate': false,
                  'activate': function(event, ui){
                    return highlightInSource(ui.newHeader.text());
                  }
                });
              });
            });
          });
        });
      });
    });
  });
}).call(this);
