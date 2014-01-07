"use strict"

assert = require 'assert'
server = require '../coffee/server.coffee'

cookie = null

before (done) ->
  opts =
    method: 'POST'
    url: '/login'
    payload: 'username=turbo%40dnt.org&password=helttopp'
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': 42

  server.inject opts, (res) ->
    assert.equal res.raw.res.statusCode, 302
    assert res.raw.res._headers['set-cookie'] instanceof Array
    assert.equal typeof res.raw.res._headers['set-cookie'][0].split(';')[0], 'string'
    cookie = "Cookie": res.raw.res._headers['set-cookie'][0].split(';')[0]
    done()

describe '/liste', ->
  it 'should display a list of cabins', (done) ->
    server.inject method: 'GET', url: '/liste', headers: cookie, (res) ->
      assert.equal res.raw.res.statusCode, 200
      done()
