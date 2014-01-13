"use strict"

Server = require('hapi').Server
path   = require 'path'
auth   = require './controller/auth'
site   = require './controller/site'
cabin  = require './controller/cabin'

port = parseInt(process.env.PORT_WWW, 10) or 8080
server = module.exports = new Server port,
  views:
    engines:
      html: 'handlebars'
    layout: true
    path: path.join(__dirname, '../', 'views')
    partialsPath: path.join(__dirname, '../', 'views', 'partials')
    helpersPath: path.join(__dirname, '../', 'views', 'helpers')

server.state 'session',
  ttl: 24 * 60 * 60 * 1000
  isHttpOnly: true
  path: '/'
  encoding: 'base64json'
  password: '620633670888786'

server.auth.scheme 'cookie', auth.scheme
server.auth.strategy 'default', 'cookie', true, foo: 'bar'

# Index
server.route
  method: 'GET'
  path: '/'
  config:
    handler: site.getIndex
    auth:
      mode: 'try'

# Auth
server.route
  method: 'GET'
  path: '/static/{path*}'
  config:
    handler: site.getStatic
    auth: false
server.route
  method: '*'
  path: '/login'
  config:
    handler: auth.allLogin
    auth:
      mode: 'try'
server.route
  method: 'GET',
  path: '/login/dnt'
  config:
    handler: auth.getConnect
    auth:
      mode: 'try'
server.route
  method: 'POST'
  path: '/login/dnt'
  config:
    handler: auth.postConnect
    auth:
      mode: 'try'
server.route
  method: 'GET'
  path: '/logout'
  config:
    handler: auth.getLogout
    auth: true

# Cabin
server.route
  method: 'GET'
  path: '/liste'
  config:
    handler: cabin.getList
    auth: true
server.route
  method: 'GET'
  path: '/hytte/{id}/endre'
  config:
    handler: cabin.getCabin
    auth: true

server.ext 'onPreResponse', (request, next) ->
  if request.path.substr(0, 21) is '/static/images/cabin/'
    if request.response instanceof Error
      id = request.path.replace('/static/images/cabin/', '')
      return cabin.fetchImage(id, next) if /^[0-9a-f]{24}$/.test id
    else
      request.response.headers['content-type'] = 'image/jpeg'
  else if request.response.isBoom and request.response.output.statusCode is 401
    # @TODO(starefossen) only redirect if accept-encoding is html
    url = '/login?redirect=' + encodeURIComponent(request.raw.req.url)
    request.response.output.headers['Location'] = url

  next()

if not module.parent
  server.start () ->
    console.log 'Server is running...'
else
  module.exports = server

