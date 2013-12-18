root = exports ? this

#_ = require 'prelude-ls'

textBody = root.textBody = '''
function qsort(array, begin, end)
{
  if(end-1>begin) {
    var pivot=begin+Math.floor(Math.random()*(end-begin));

    pivot=partition(array, begin, end, pivot);

    qsort(array, begin, pivot);
    qsort(array, pivot+1, end);
  }
}
'''

root.fromLang = 'javascript'
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
  for x in $('.highlighted')
    console.log x
    $(x).removeClass('highlighted')
    if $(x).attr('ismethod') == 'true'
      $(x).addClass('bluehighlight')
  for x in $('.SOURCE' + word.split('.').join('-'))
    $(x).removeClass('bluehighlight')
    $(x).addClass('highlighted')

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

getCallExpressions = (programText, callback) ->
  $.get '/getCallExpressions?' + $.param({phrase: programText}), (data) ->
    data |> JSON.parse |> callback

sortCompare = (a,b) ->
  | a > b => 1
  | a < b => -1
  | otherwise => 0

githubSearchCodeAsync = (searchTerm, callback) ->
  $.get '/searchCode?' + $.param({searchTerm: searchTerm, lang: 'javascript'}), (results) ->
    callback(null, JSON.parse(results))

stackoverflowSearchAsync = (searchTerm, callback) ->
  $.get '/searchStackOverflow?' + $.param({q: searchTerm}), (results) ->
    callback(null, JSON.parse(results))

setTextWithNewlines = (elem, text) ->
  for x in elem
    x.innerText = text
  return elem

$(document).ready ->
  urlParams = getUrlParameters()
  if urlParams.from?
    root.fromLang = urlParams.from
  if urlParams.dest?
    root.destLang = urlParams.dest
  if urlParams.text? and not root.textBody?
    root.textBody = unescape(urlParams.text)
  callExpressions <- getCallExpressions root.textBody
  callExpressions.sort (a,b) -> sortCompare a.start, b.start
  #callExpressions.reverse()
  spanStartIdx = 0
  for {start, end, text} in callExpressions
    if start > spanStartIdx
      $('#codeDisplay').append (setTextWithNewlines $('<span>'), root.textBody[spanStartIdx til start].join('')).addClass('code')
    $('#codeDisplay').append (setTextWithNewlines $('<span>'), text).addClass('SOURCE' + text.split('.').join('-')).addClass('bluehighlight').attr('ismethod', 'true').attr('methodname', text).attr('onclick', 'wordClicked("' + text + '")').addClass('code')
    spanStartIdx = end
    console.log text
  if spanStartIdx < root.textBody.length
    $('#codeDisplay').append (setTextWithNewlines $('<span>'), root.textBody[spanStartIdx to].join('')).addClass('code')
  #console.log callExpressions
  root.wordsSortedByFreq = _.uniq [text for {text} in callExpressions]
  (err0, root.githubSearchResults) <- async.map root.wordsSortedByFreq, githubSearchCodeAsync
  (err1, root.stackoverflowSearchResults) <- async.map root.wordsSortedByFreq, stackoverflowSearchAsync
  #for [text,githubResults] in _.zip root.wordsSortedByFreq, githubSearchResults
  for [text,githubResults,stackoverflowResults] in _.zip root.wordsSortedByFreq, root.githubSearchResults, root.stackoverflowSearchResults
    $('#explanationDisplay').append $('<h3>').html(text).attr('id', 'HEADER' + text.split('.').join('-'))
    expdiv = $('<div>')
    expdiv.append $('<a>').text('StackOverflow:').attr('href', 'https://stackoverflow.com/search?q=' + text).attr('target', '_blank').css('color', 'blue')
    expdiv.append $('<br>')
    for sores in stackoverflowResults[0 til 3]
      expdiv.append $('<br>')
      expdiv.append $('<a>').html(sores.title).attr('href', sores.link).attr('target', '_blank')
      console.log sores
    expdiv.append $('<br>')
    expdiv.append $('<br>')
    expdiv.append $('<a>').text('Github:').attr('href', 'https://github.com/search?type=Code&q=' + text).attr('target', '_blank').css('color', 'blue')
    expdiv.append $('<br>')
    for ghres in githubResults[0 til 3]
      expdiv.append $('<br>')
      expdiv.append $('<a>').text(ghres.path).attr('href', ghres.html_url).attr('target', '_blank')
      expdiv.append $('<br>')
      expdiv.append (setTextWithNewlines $('<span>'), ghres.text_matches[0].fragment).addClass('code')
      expdiv.append $('<br>')
      console.log ghres
    $('#explanationDisplay').append expdiv
    #$('#explanationDisplay').append $('<div>').html(text)
  $('#explanationDisplay').accordion {
    'heightStyle': 'content',
    'collapsible': true,
    'active': false,
    'animate': false,
    'activate': (event, ui) -> highlightInSource(ui.newHeader.text().split('.').join('-'))
  }

  return
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

