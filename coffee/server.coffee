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
  #console.log request.response() instanceof Error
  #console.log request.path.substr 0, 21
  #console.log request.response().isBoom
  #console.log request.response()._code
  next()

if not module.parent
  server.start () ->
    console.log 'Server is running...'
else
  module.exports = server

