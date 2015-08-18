var express = require('express'),
    path = require('path'),
    httpProxy = require('http-proxy'),
    http = require('http'),
    proxy = httpProxy.createProxyServer({
      changeOrigin: true,
      ws: true
    }),
    app = express(),
    isProduction = (process.env.NODE_ENV == 'production'),
    port = isProduction ? process.env.PORT : 3000,
    publicPath = path.resolve(__dirname, 'public');

 app.use(express.static(publicPath));


 if (!isProduction) {
   var bundle = require('./server/bundle.js');
   bundle();

   app.all('/build/*', function(req, res) {
     proxy.web(req, res, {
       target: 'http://localhost:3001'
     });
   });

   proxy.on('error', function(e) {
     console.log('Could not connect to proxy, please try again...');
   });

   var server = http.createServer(app);

   server.on('upgrade', function(req, socket, head) {
     proxy.ws(req, socket, head);
   });

   server.listen(port, function() {
     console.log('Server running on port ' + port);
   });

 } else {
   app.listen(port, function() {
     console.log('Server running on port ' + port);
   });

 }
