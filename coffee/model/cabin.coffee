"use strict"

cache = './cache'
request = require 'request'

api_key = process.env.NTB_API_KEY

exports.getCabins = (group, cb) ->
  url = "http://dev.nasjonalturbase.no/steder?gruppe=#{group}&api_key=#{api_key}"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body.documents

exports.getCabin = (id, cb) ->
  url = "http://api.nasjonalturbase.no/steder/#{id}?api_key=#{api_key}"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body

exports.getImage = (id, cb) ->
  url = "http://api.nasjonalturbase.no/bilder/#{id}?api_key=#{api_key}"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body

