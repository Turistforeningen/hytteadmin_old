"use strict"

EventEmitter = require('events').EventEmitter
MongoClient = require('mongodb').MongoClient
inherits = require('util').inherits

Mongo = (uri) ->
  EventEmitter.call @
  @db = null

  new MongoClient.connect uri, (err, database) =>
    throw err if err
    @db = database
    @emit 'ready'

  @

inherits Mongo, EventEmitter

module.exports = new Mongo(process.env.MONGO_URI)

