root = exports ? this

#acorn = require 'acorn'
esprima = require 'esprima'
walk = require 'acorn/util/walk'

programExample = '''
b = Math.sqrt(35)
q = sad.dfjnkg.sdfa(4)
r = wer(1)
'''

# input: program text of a Javascript program
# output: list of {start:, end:, text:}
getCallExpressions = root.getCallExpressions = (programText) ->
  output = []
  #walk.simple acorn.parse(programText), {
  walk.simple esprima.parse(programText, {range: true}), {
    CallExpression: (node) ->
      callee = {[k,v] for k,v of node.callee}
      callee.start ?= callee.range[0]
      callee.end ?= callee.range[1]
      output.push callee
  }
  return [{start: x.start, end: x.end, text: programText[x.start til x.end].join('')} for x in output]
  return output
  memberExpressions.sort (a,b) -> (a.end - a.start) > (b.end - b.start)
  memberExpressions.reverse()
  covered = {}
  nonOverlappingMemberExpressions = []
  for node in memberExpressions
    isCovered = false
    for idx in [node.start to node.end]
      if covered[idx]?
        isCovered = true
        break
    if isCovered
      continue
    for idx in [node.start to node.end]
      covered[idx] = true
    nonOverlappingMemberExpressions.push node
  return nonOverlappingMemberExpressions

main = ->
  console.log (getCallExpressions programExample)

main() if require.main is module