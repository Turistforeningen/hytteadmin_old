"use strict"

assert = require 'assert'
server = require '../coffee/server.coffee'

describe 'auth', ->
  require './auth-spec.coffee'

describe 'cabin', ->
  require './cabin-spec.coffee'
