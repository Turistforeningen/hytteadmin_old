"use strict"

Server = require('hapi').Server
path   = require 'path'
auth   = require './controller/auth'
site   = require './controller/site'
cabin  = require './controller/cabin'

server = module.exports = new Server 8080,
  views:
    engines:
      html: 'handlebars'
    layout: true
    path: path.join(__dirname, '../', 'views')
    partialsPath: path.join(__dirname, '../', 'views', 'partials')
    helpersPath: path.join(__dirname, '../', 'views', 'helpers')
  auth:
    scheme: 'cookie'
    password: 'secret'
    cookie: 'a'
    redirectTo: '/login'
    isSecure: false

server.route [
  { method: 'GET', path: '/'      , config: { handler: site.getIndex  , auth: { mode: 'try' }}}
  #{ method: 'GET', path: '/static/images/cabin/{id}', handler: cabin.getImage }
  { method: 'GET', path: '/static/{path*}'  , handler: site.getStatic }
  { method: '*'  , path: '/login' , config: { handler: auth.allLogin  , auth: { mode: 'try' }}}
  { method: 'GET', path: '/logout', config: { handler: auth.getLogout , auth: true }}
  { method: 'GET', path: '/liste'  , config: { handler: cabin.getList  , auth: true }}
  { method: 'GET', path: '/hytte/{id}'  , config: { handler: cabin.getCabin, auth: true }}
]

server.ext 'onPreResponse', (request, next) ->
  if request.path.substr(0, 21) is '/static/images/cabin/'
    if request.response() instanceof Error
      id = request.path.replace('/static/images/cabin/', '')
      return cabin.fetchImage(id, next) if /^[0-9a-f]{24}$/.test id
    else
      request._response.headers['content-type'] = 'image/jpeg'

  next()

if not module.parent
  server.start () ->
    console.log 'Server is running...'
else
  module.exports = server

