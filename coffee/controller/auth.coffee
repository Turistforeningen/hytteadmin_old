"use strict"

site = require './../model/config'

exports.allLogin = (request, reply) ->
  return reply().redirect '/' if request.auth.isAuthenticated

  if request.method is 'post'
    if request.payload?.username and request.payload?.password
      if request.payload.username is 'turbo@dnt.org' and request.payload.password is 'helttopp'
        request.auth.session.set id: 0, name: 'Turbo', email: 'turbo@dnt.org'
        return reply().redirect '/'
      else
        error = 'Invalid username or password'
    else
      error = 'Missing username or password'

  reply.view 'login', {site: site, title: 'Login', error: error}, {layout: false}

exports.getLogout = (request, reply) ->
  request.auth.session.clear()
  reply().redirect '/'

