"use strict"

site = require '../model/config'
cabin = require '../model/cabin'

exports.getList = (request, reply) ->
  reply.view 'list',
    site: site
    user: request.auth.credentials
    cabins: cabin.getCabins()
    title: 'List'

exports.getCabin = (request, reply) ->
  cabin.getCabin request.params.id, (err, data) ->
    return reply.redirect '/' if err
    reply.view 'cabin',
      site: site
      user: request.auth.credentials
      cabin: data
      title: 'Endre hytte'

exports.getImage = (request, reply) ->
  cabin.getCabin request.params.id, (err, data) ->
    return reply().code(404) if err or not data?.bilder?[0]
    cabin.getImage data.bilder[0], (err, data) ->
      return reply().code(404) if err or not data?.img?[1]
      stream = require('request')(data.img[1].url)
      stream.once 'response', reply

