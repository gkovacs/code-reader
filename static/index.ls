root = module ? this

codeBody = root.codeBody = '''
a = Math.sqrt(3)
'''

$(document).ready ->
  ast = acorn.parse(codeBody)
  #console.log ast
  memberExpressions = []
  acorn.walk.simple(ast, {'MemberExpression': (x) -> memberExpressions.push x})
  for memberExpression in memberExpressions
    console.log memberExpression
  $('#codeDisplay').text(codeBody)

