"use strict"

path   = require 'path'
Server = require('hapi').Server
site   = {}

internals = {}

internals.getIndex = (request, reply) ->
  return reply.redirect '/login' if not request.auth.isAuthenticated
  reply.redirect '/list'

internals.allLogin = (request, reply) ->
  return reply.redirect '/' if request.auth.isAuthenticated

  if request.method is 'post'
    if request.payload?.username and request.payload?.password
      if request.payload.username is 'foo' and request.payload.password is 'bar'
        request.auth.session.set id: 0, name: 'foo', password: 'bar'
        return reply.redirect '/'
      else
        error = 'Invalid username or password'
    else
      error = 'Missing username or password'

  reply.view 'login', {site: site, title: 'Login', error: error}, {layout: false}

internals.getLogout = (request, reply) ->
  request.auth.session.clear()
  reply.redirect '/'

internals.getList = (request, reply) ->
  reply.view 'list', site: site, title: 'List'

internals.getStatic =
  directory:
    path: path.join(__dirname, '../', 'static')
    redirectToSlash: true

internals.main = () ->
  options =
    views:
      engines:
        html: 'handlebars'
      path: path.join(__dirname, '../', 'views')
      layout: true
      partialsPath: path.join(__dirname, '../', 'views', 'partials')
      helpersPath: path.join(__dirname, '../', 'views', 'helpers')
    auth:
      scheme: 'cookie'
      password: 'secret'
      cookie: 'a'
      redirectTo: '/login'
      isSecure: false

  server = new Server(8080, options)
  server.route [
    { method: 'GET', path: '/'      , config: { handler: internals.getIndex , auth: { mode: 'try' }}}
    { method: '*'  , path: '/login' , config: { handler: internals.allLogin , auth: { mode: 'try' }}}
    { method: 'GET', path: '/logout', config: { handler: internals.getLogout, auth: true }}
    { method: 'GET', path: '/list'  , config: { handler: internals.getList  , auth: true }}
    { method: 'GET', path: '/static/{path*}'  , handler: internals.getStatic }
  ]
  server.start () ->
    console.log 'Server is running...'

internals.main()

