"use strict"

cache = require './cache'
mongo = require './mongo'
request = require 'request'
ObjectID = require('mongodb').ObjectID

api_key = process.env.NTB_API_KEY

exports.getCabins = (group, cb) ->
  url = "http://dev.nasjonalturbase.no/steder?gruppe=#{group}&api_key=#{api_key}"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body.documents


getCabinFromNtb = (id, after, cb) ->
  opts =
    url: "http://api.nasjonalturbase.no/steder/#{id}?api_key=#{api_key}"
    headers: "If-Modified-Since": after if after
    json: true
  request opts, (err, res, body) ->
    cb err, res.statusCode, body

getCabinFromCache = (id, cb) ->
  cache.hgetall "cabin:#{id}", cb

getCabinFromDb = (id, cb) ->
  mongo.db.collection('cabin').findOne _id: new ObjectID(id), cb

cacheCabin = (id, cabin, cb) ->
  cache.hmset "cabin:#{id}",
    name    : cabin.navn
    checksum: cabin.checksum
    endret  : cabin.endret
    url     : cabin.url
    groups  : cabin.grupper

  cabin._id = new ObjectID cabin._id
  mongo.db.collection('cabin').save cabin, (err) ->
    cb err, cabin

exports.getCabin = (id, cb) ->
  getCabinFromCache id, (err, c) ->

    return cb null, null if c and c.status is 'Slettet'

    getCabinFromNtb id, c?.endret, (err, code, cabin) ->
      if code is 304
        return getCabinFromDb id, (err, doc) ->
          return cb null, doc if doc
          return getCabinFromNtb id, null, (err, code, cabin) ->
            return cacheCabin id, cabin, cb if code is 200
            return cb new Error('NTB Failed')

      else if code is 200
        return cacheCabin id, cabin, cb

      else
        cache.hset "cabin:#{id}", "status", "Slettet"
        cache.expire "cabin:#{id}", 600
        return cb null, null

exports.getImage = (id, cb) ->
  url = "http://api.nasjonalturbase.no/bilder/#{id}?api_key=#{api_key}"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body

