"use strict"

site = require '../model/config'
cabin = require '../model/cabin'
request = require 'request'
fs = require 'fs'

exports.getList = (request, reply) ->
  reply.view 'list',
    site: site
    user: request.auth.credentials
    cabins: cabin.getCabins()
    title: 'List'

exports.getCabin = (request, reply) ->
  cabin.getCabin request.params.id, (err, data) ->
    return reply().redirect '/' if err
    reply.view 'cabin',
      site: site
      user: request.auth.credentials
      cabin: data
      title: 'Endre hytte'

exports.fetchImage = (id, reply) ->
  cabin.getCabin id, (err, data) ->
    # @TODO(starefossen) code is undefined
    return reply().code(404) if err or not data?.bilder?[0]
    cabin.getImage data.bilder[0], (err, data) ->
      # @TODO(starefossen) code is undefined
      return reply().code(404) if err or not data?.img?[1]
      stream = request data.img[1].url
      stream.once 'response', reply
      stream.pipe fs.createWriteStream('static/images/cabin/' + id)

