var httpProxy = require('http-proxy'),
    connect   = require('connect'),
    endpoint  = {
      host:   'stackoverflow.com', // or IP address
      port:   80,
      prefix: '/'
    },
    staticDir = 'public';
 
var proxy = new httpProxy.RoutingProxy();
var app = connect()
  .use(connect.logger('dev'))
  .use(function(req, res) {
    if (req.url.indexOf(endpoint.prefix) === 0) {
      proxy.proxyRequest(req, res, endpoint);
    }
  })
  .use(connect.static(staticDir))
  .listen(3457);
 
// http://localhost:4242/api/test will give response
// from http://your-app-domain.com/api/test
