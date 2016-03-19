var express = require('express'),
    app = express();

var SERVER_PORT = process.env.PORT || 8000;

app.get('/', function (req, res) {
    res.end('Test');
});

app.listen(SERVER_PORT, function(){
    console.log('Listening on 8000');
});
