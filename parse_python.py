import ast

programText = '''
print len([3,4,5])
'''

tree = ast.parse(programText)
for node in ast.walk(tree):
  #print node
  if isinstance(node, ast.Call):
    #print node.func, dir(node.func), ast.dump(node)
    #print node.func.id
    print ast.dump(node.func)
