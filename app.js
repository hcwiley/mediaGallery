/**
 * Module dependencies.
 */

var config = require('./config')
  , express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path')
  , jadeBrowser = require('jade-browser')
  , socketIo = require('socket.io')
  , mongoose = require('mongoose')
  , models = require('./models')
  , User = models.User
  , MongoStore = require('connect-mongo')(express)
  , sessionStore = new MongoStore({ url: config.mongodb })
;

// connect the database
mongoose.connect(config.mongodb);

// create app, server, and web sockets
var app = express()
  , server = http.createServer(app)
  , io = socketIo.listen(server)
;

// Make socket.io a little quieter
io.set('log level', 1);
// Give socket.io access to the passport user from Express
io.set('authorization', passportSocketIo.authorize({
  sessionKey: 'connect.sid',
  sessionStore: sessionStore,
  sessionSecret: config.sessionSecret,
  fail: function(data, accept) { // keeps socket.io from bombing when user isn't logged in
    accept(null, true);
  }
}));

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');

  // export jade templates to reuse on client side
  app.use(jadeBrowser('/js/templates.js', ['*.jade', '*/*.jade'], { root: __dirname + '/views' }));

  // use the connect assets middleware for Snockets sugar
  app.use(require('connect-assets')());

  app.use(express.favicon());
  app.use(express.logger(config.loggerFormat));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser(config.sessionSecret));
  app.use(express.session({ store: sessionStore }));
  app.use(passport.initialize());
  app.use(passport.session());
  app.use(app.router);
  
  app.use(require('less-middleware')({ src: __dirname + '/public' }));
  app.use(express.static(path.join(__dirname, 'public')));

  if(config.useErrorHandler) app.use(express.errorHandler());
});

// UI routes
app.get('/', routes.index);
