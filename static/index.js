// Generated by LiveScript 1.3.1
(function(){
  var root, codeBody;
  root = typeof module != 'undefined' && module !== null ? module : this;
  codeBody = root.codeBody = 'a = Math.sqrt(3)';
  $(document).ready(function(){
    var ast, memberExpressions, i$, len$, memberExpression;
    ast = acorn.parse(codeBody);
    memberExpressions = [];
    acorn.walk.simple(ast, {
      'MemberExpression': function(x){
        return memberExpressions.push(x);
      }
    });
    for (i$ = 0, len$ = memberExpressions.length; i$ < len$; ++i$) {
      memberExpression = memberExpressions[i$];
      console.log(memberExpression);
    }
    return $('#codeDisplay').text(codeBody);
  });
}).call(this);
