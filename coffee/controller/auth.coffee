"use strict"

site = require './../model/config'
boom = require('hapi').error

Connect = new require('dnt-connect')
client = new Connect('hytteadmin', process.env.DNT_CONNECT)

exports.scheme = (server, options) ->
  scheme = {}

  scheme.authenticate = (request, reply) ->
    return reply boom.unauthorized('Unauthorized') if not request.state.session
    return reply null, credentials: request.state.session

  scheme.payload = (request, next) ->
    next(request.auth.credentials.payload)

  scheme.response = (request, next) ->
    next()

  return scheme

exports.getConnect = (request, reply) ->
  return reply().redirect '/' if request.auth.isAuthneticated

  if request.method is 'post'
    return reply().redirect client.signon(process.env.APP_URL + 'login/dnt')
  else
    return reply().redirect('/login?error=DNTC-501') if not request?.query?.data?

    try
      data = client.decryptJSON(request.query.data)
    catch e
      # @TODO(starefossen) check e and return appopriate error
      return reply().redirect('/login?error=DNTC-502')

    return reply().redirect('/ligin?error=DNTC-503') if not data.er_autentisert

    session = sherpa_id: data.sherpa_id, name: data.fornavn, email: data.epost
    return reply().state('session', session).redirect '/'

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

  # @TODO(starefossen) parse request.query.error here

  reply.view 'login', {site: site, title: 'Login', error: error}, {layout: false}

exports.getLogout = (request, reply) ->
  reply().unstate('session').redirect '/'

