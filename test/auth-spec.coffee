"use strict"

assert = require 'assert'
server = require '../coffee/server.coffee'
Connect = require 'dnt-connect'

exports.cookie = cookie = null

describe '/login', ->
  it 'should server a login page', (done) ->
    server.inject method: 'GET', url: '/login', (res) ->
      assert.equal res.statusCode, 200
      assert /<input type="text" name="username"/.test(res.payload)
      assert /<input type="password" name="password"/.test(res.payload)
      done()

  it 'should reject invalid user credentials', (done) ->
    p = 'username=foo&password=bar'
    h =
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': p.length

    server.inject method: 'POST', url: '/login', payload: p, headers: h, (res) ->
      assert.equal res.raw.res.statusCode, 200
      assert typeof res.raw.res._headers['set-cookie'], 'undefined'
      done()

  it 'should authenticate existing user successfully', (done) ->
    p = 'username=turbo%40dnt.org&password=helttopp'
    h =
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': p.length

    server.inject method: 'POST', url: '/login', payload: p, headers: h, (res) ->
      assert.equal res.raw.res.statusCode, 302
      assert res.raw.res._headers['set-cookie'] instanceof Array
      assert.equal typeof res.raw.res._headers['set-cookie'][0].split(';')[0], 'string'
      cookie = res.raw.res._headers['set-cookie'][0].split(';')[0]
      done()

  it 'should redirect authenticated user', (done) ->
    h = "Cookie": cookie
    server.inject method: 'GET', url: '/', headers: h, (res) ->
      assert.equal res.raw.res.statusCode, 302
      assert /\/liste$/.test res.raw.res._headers.location
      done()

describe '/login/dnt', ->
  c = new Connect 'hytteadmin', process.env.DNT_CONNECT

  cMock = (auth, signon) ->
    signon = 'pålogget' if not signon and auth
    signon = 'avbrutt'  if not signon and auth

    c.encryptJSON
      er_autentisert: auth
      timestamp     : Math.floor(new Date().getTime() / 1000)
      språkkode     : 'nb'
      signon        : signon
      er_medlem     : true
      aktivt_medlemskap: true
      sherpa_id     : 1337
      medlemsnummer : 1234567
      fornavn       : 'Ola'
      etternavn     : 'Nordmann'
      født          : '1990-01-01'
      kjønn         : 'M'
      epost         : 'ola@nordmann.no'
      mobil         : '987 65 432'

  it 'should redirect user to DNT Connect', (done) ->
    server.inject method: 'POST', url: '/login/dnt', (res) ->
      assert.equal res.raw.res.statusCode, 302
      regexp = /https:\/\/www.turistforeningen.no\/connect\/signon\/\?client=hytteadmin\&data=/
      regexp.test res.headers.location
      done()

  it 'should fail gracefully for missing data parameter', (done) ->
    server.inject method: 'GET', url: '/login/dnt', (res) ->
      assert.equal res.raw.res.statusCode, 422
      assert.equal res.raw.res._headers.location, 'http://0.0.0.0:8080/login?error=DNTC-501'
      assert typeof res.raw.res._headers['set-cookie'], 'undefined'
      done()

  it 'should fail gracefully for malformed data parameter', (done) ->
    server.inject method: 'GET', url: '/login/dnt?data=foobar', (res) ->
      assert.equal res.raw.res.statusCode, 422
      assert.equal res.raw.res._headers.location, 'http://0.0.0.0:8080/login?error=DNTC-502'
      assert typeof res.raw.res._headers['set-cookie'], 'undefined'
      done()

  it 'should fail gracefully for malformed json data', (done) ->
    data = encodeURIComponent c.encrypt '--foo'
    server.inject method: 'GET', url: "/login/dnt?data=#{data}", (res) ->
      assert.equal res.raw.res.statusCode, 422
      assert.equal res.raw.res._headers.location, 'http://0.0.0.0:8080/login?error=DNTC-502'
      assert typeof res.raw.res._headers['set-cookie'], 'undefined'
      done()

  it 'should not authenticate invalid user from DNT Connect', (done) ->
    server.inject method: 'GET', url: "/login/dnt?data=#{cMock(false)}", (res) ->
      assert.equal res.raw.res.statusCode, 401
      assert.equal res.raw.res._headers.location, 'http://0.0.0.0:8080/login?error=DNTC-503'
      assert typeof res.raw.res._headers['set-cookie'], 'undefined'
      done()

  it 'should authenticated valid user from DNT Connect', (done) ->
    server.inject method: 'GET', url: "/login/dnt?data=#{cMock(true)}", (res) ->
      assert.equal res.raw.res.statusCode, 302
      assert.equal res.raw.res._headers.location, 'http://0.0.0.0:8080/'
      assert res.raw.res._headers['set-cookie'] instanceof Array
      assert.equal typeof res.raw.res._headers['set-cookie'][0].split(';')[0], 'string'
      cookie = res.raw.res._headers['set-cookie'][0].split(';')[0]
      done()

describe '/logout', ->
  it 'should logout authenticated user', (done) ->
    h = "Cookie": cookie
    server.inject method: 'GET', url: '/logout', headers: h, (res) ->
      assert.equal res.raw.res.statusCode, 302
      assert.equal res.raw.res._headers['set-cookie'][0].split(';')[0], 'session='
      assert /\/$/.test res.raw.res._headers.location
      done()

