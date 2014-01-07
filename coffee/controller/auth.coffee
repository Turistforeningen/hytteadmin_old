"use strict"

site = require './../model/config'
boom = require('hapi').error

exports.scheme = (server, options) ->
  scheme = {}

  scheme.authenticate = (request, reply) ->
    return reply boom.unauthorized('Unauthorized', 'cookie') if not request.state.session
    return reply null, credentials: request.state.session

  scheme.payload = (request, next) ->
    next(request.auth.credentials.payload)

  scheme.response = (request, next) ->
    next()

  return scheme

exports.allLogin = (request, reply) ->
  return reply().redirect '/' if request.auth.isAuthenticated

  if request.method is 'post'
    if request.payload?.username and request.payload?.password
      if request.payload.username is 'turbo@dnt.org' and request.payload.password is 'helttopp'
        session = id: 0, name: 'Turbo', email: 'turbo@dnt.org'
        return reply().state('session', session).redirect '/'
      else
        error = 'Invalid username or password'
    else
      error = 'Missing username or password'

  reply.view 'login', {site: site, title: 'Login', error: error}, {layout: false}

exports.getLogout = (request, reply) ->
  reply().unstate('session').redirect '/'

