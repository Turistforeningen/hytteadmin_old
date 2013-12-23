"use strict"

assert = require 'assert'
server = require '../coffee/server.coffee'

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

describe '/logout', ->
  it 'should logout authenticated user', (done) ->
    h = "Cookie": cookie
    server.inject method: 'GET', url: '/logout', headers: h, (res) ->
      assert.equal res.raw.res.statusCode, 302
      assert.equal res.raw.res._headers['set-cookie'][0].split(';')[0], 'a='
      assert /\/$/.test res.raw.res._headers.location
      done()

