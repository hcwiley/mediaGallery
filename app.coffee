###
Module dependencies.
###
config = require("./config")
express = require("express")
path = require("path")
http = require("http")
socketIo = require("socket.io")
osc = require("osc.io")
mongoose = require("mongoose")
MongoStore = require("connect-mongo")(express)
sessionStore = new MongoStore(url: config.mongodb)

# connect the database
mongoose.connect config.mongodb

# create app, server, and web sockets
app = express()
server = http.createServer(app)
io = socketIo.listen(server)

# Make socket.io a little quieter
io.set "log level", 1

# Give socket.io access to the passport user from Express
#io.set('authorization', passportSocketIo.authorize({
#sessionKey: 'connect.sid',
#sessionStore: sessionStore,
#sessionSecret: config.sessionSecret,
#fail: function(data, accept) { // keeps socket.io from bombing when user isn't logged in
#accept(null, true);
#}
#}));
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  
  # use the connect assets middleware for Snockets sugar
  app.use require("connect-assets")()
  app.use express.favicon()
  app.use express.logger(config.loggerFormat)
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser(config.sessionSecret)
  app.use express.session(store: sessionStore)
  app.use app.router
  app.use require("less-middleware")(src: __dirname + "/public")
  app.use express.static(path.join(__dirname, "public"))
  app.use osc(io,
    log: false
  )
  
  #app.use(osc(io));
  app.use express.errorHandler()  if config.useErrorHandler

entries = {}

updateGallery = (next) ->
  options = {
    host: "127.0.0.1",
    port: 8000,
    path: "/json/gallery",
    agent: false
  }
  data = ""
  http.get options, (getRes) ->
    console.log "status: #{getRes.statusCode}"
  .on 'response', (getRes) ->
    getRes.on "data", (chunk) ->
      data += chunk.toString('ASCII')
    getRes.on "end", () ->
      #data = JSON.stringify data
      data = data.replace /\r\n/g, " "
      data = data.replace /\n/g, " "
      data = data.replace /\r/g, " "
      data = JSON.parse data
      #console.log data
      entries = data.entries
      for entry, key in data.entries
        entries.key = entry
      #res.end JSON.stringify entries
      next()
  .on 'error', (e) ->
    console.log "ERROR: #{e.message}"
    next('error')

# UI routes
app.get "/", (req, res) ->
  updateGallery (e) ->
    res.render "index.jade",
      title: "Media Gallery"
      objects: entries


server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
