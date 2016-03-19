var express = require('express'),
    app = express();

var SERVER_PORT = process.env.PORT || 8000;

app.use(express.static('client'));

app.listen(SERVER_PORT, function(){
    console.log('Listening on 8000');
});
