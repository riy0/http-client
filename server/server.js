var http = require('http');

var server = http.createServer(function (req, res) {
  console.log(`headers: ${JSON.stringify(req.headers)}`);
  console.log(`method: ${req.method}`);
  console.log(`url: ${req.url}`);

  // response
  res.writeHeader(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({ 'id': 1}));
});

server.listen({
  port: 80
});
