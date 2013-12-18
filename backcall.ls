f = (x,cb) -> cb x*2

output = []
while output.length < 3
  n <- f (output.length + 1)
  output.push n
console.log output