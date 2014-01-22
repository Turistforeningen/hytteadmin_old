"use strict"

assert = require 'assert'
server = require '../coffee/server.coffee'

mongo = cache = null

before (done) ->
  mongo = require '../coffee/model/mongo.coffee'
  cache = require '../coffee/model/cache.coffee'
  mongo.once 'ready', done

beforeEach (done) ->
  cache.flushall()
  mongo.db.dropCollection 'test'
  mongo.db.dropCollection 'cabin'
  done()

describe 'mode', ->
  describe 'cabin', ->
    require './model/cabin-spec.coffee'

describe 'auth', ->
  require './auth-spec.coffee'

describe 'cabin', ->
  require './cabin-spec.coffee'
