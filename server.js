var us = require('underscore')
var fs = require('fs')

var db = JSON.parse(fs.readFileSync('db.json'))
var products = us.uniq(db.products)

var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({ port: 8080 });

wss.on('connection', function connection(ws) {
  console.log('Client connected!')

  function sendRandomProduct() {
    product = us.sample(products)
    ws.send(JSON.stringify(product)); 
  }

  var timer = setInterval(sendRandomProduct, 2000);

  ws.on('close', ( ) => {
    console.log('Client disconnected!');
    clearInterval(timer);
  })
});
