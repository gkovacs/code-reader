root = exports ? this

#_ = require 'prelude-ls'

textBody = root.textBody = '''
the quick brown fox jumped over the lazy dog
'''

root.fromLang = 'en'
root.destLang = 'en'

root.wordToFrequency = {}
root.wordToInfo = {}
root.wordsSortedByFreq = []
root.wordToSourceIndexes = {}

getWordFreq = root.getWordFreq = (word, callback) ->
  $.get ('/getWordFreq?' + $.param({'phrase': word, 'from': root.fromLang, 'dest': root.destLang})), (data) ->
    callback(null, parseInt(data))

getDefinitions = root.getDefinitions = (word, callback) ->
  $.get ('/getDefinitions?' + $.param({'phrase': word, 'from': root.fromLang, 'dest': root.destLang})), (data) ->
    callback(null, data)

getExamples = root.getExamples = (word, callback) ->
  $.get ('/getExamples?' + $.param({'phrase': word, 'from': root.fromLang, 'dest': root.destLang})), (data) ->
    callback(null, data)

toText = (html) ->
  $('<span>').html(html).text()

generateWordBox = (word, definitions, examples) ->
  wordDiv = $('<h3>').html(word).css('background-color', 'blue')
  definitionDiv = $('<div>').text([toText(x) for x in definitions[0 til 3]].join('; ')).css('font-style', 'normal')
  exampleDiv = $('<div>').text(toText(examples[0])).css('font-style', 'italic')
  childDiv = $('<div>').append(definitionDiv).append(exampleDiv)
  return childDiv.html()
  #console.log (wordDiv.append(childDiv)).html()
  #return wordDiv.append(childDiv)

expandWord = root.expandWord = (word) ->
  wordIdx = root.wordsSortedByFreq.indexOf word
  if wordIdx >= 0
    $('#explanationDisplay').accordion('option', 'active', wordIdx)
    topOffset = $('#HEADER' + word).offset().top
    console.log 'topOffset is:' + topOffset
    $('#rightFrame').animate {'scrollTop': topOffset + $('#rightFrame').scrollTop()}

highlightInSource = root.highlightInSource = (word) ->
  $('.highlighted').removeClass('highlighted')
  $('.SOURCE' + word).addClass('highlighted')

wordClicked = root.wordClicked = (word) ->
  highlightInSource word
  expandWord word

tokenize = root.tokenize = (text, delimiterList) ->
  tokenList = []
  currentToken = []
  for c in text
    if (delimiterList.indexOf c) == -1
      currentToken.push c
    else
      if currentToken.length > 0
        tokenList.push (currentToken.join '')
      tokenList.push c
      currentToken = []
  if currentToken.length > 0
    tokenList.push (currentToken.join '')
    currentToken = []
  return tokenList

getUrlParameters = root.getUrlParameters = ->
  map = {}
  parts = window.location.href.replace /[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    map[key] = decodeURI(value)
  return map

$(document).ready ->
  urlParams = getUrlParameters()
  if urlParams.from?
    root.fromLang = urlParams.from
  if urlParams.dest?
    root.destLang = urlParams.dest
  if urlParams.text?
    root.textBody = urlParams.text
  delimiters = [' ', ',', '.', ':']
  tokens = tokenize(root.textBody, delimiters)
  words = []
  for word in tokens
    if (delimiters.indexOf word) == -1
      words.push word
  console.log words
  for token,idx in tokenize(root.textBody, delimiters)
    if not root.wordToSourceIndexes[token]?
      root.wordToSourceIndexes[token] = []
    root.wordToSourceIndexes[token].push idx
    if (delimiters.indexOf token) == -1
      $('#codeDisplay').append $('<span>').text(token).addClass('SOURCE' + token).attr('onclick', 'wordClicked("' + token + '")')
    else
      $('#codeDisplay').append $('<span>').text(token)
  #wordfreq('the', (result) -> console.log result)
  (err0, freqResults) <- async.mapSeries words, getWordFreq
  (err1, definitionResults) <- async.mapSeries words, getDefinitions
  (err2, exampleResults) <- async.mapSeries words, getExamples
  for [word, freq, definitions, examples] in _.zip(words, freqResults, definitionResults, exampleResults)
    if root.wordToFrequency[word]?
      continue
    root.wordToFrequency[word] = freq
    root.wordToInfo[word] = generateWordBox(word, definitions, examples)
  root.wordsSortedByFreq = [word for word in words]
  root.wordsSortedByFreq.sort (x,y) -> root.wordToFrequency[x] < root.wordToFrequency[y]
  root.wordsSortedByFreq = _.uniq wordsSortedByFreq, isSorted=true
  root.wordsSortedByFreq.reverse()
  for word in root.wordsSortedByFreq
    console.log word
    $('#explanationDisplay').append $('<h3>').html(word).attr('id', 'HEADER' + word)
    #$('#explanationDisplay').append $('<div>').html('foobar')
    $('#explanationDisplay').append $('<div>').html(root.wordToInfo[word])
  $('#explanationDisplay').accordion {
    'heightStyle': 'content',
    'collapsible': true,
    'active': false,
    'animate': false,
    'activate': (event, ui) -> highlightInSource(ui.newHeader.text())
  }

