"use strict"

fs      = require 'fs'
request = require 'request'

site    = require '../model/config'
cabin   = require '../model/cabin'
stats   = require '../model/statistics'

exports.getList = (request, reply) ->
  cabin.getCabins '52407f3c4ec4a1381500025d', (err, data) ->
    reply.view 'list',
      site: site
      user: request.auth.credentials
      cabins: data
      title: 'List'

exports.getCabin = (request, reply) ->
  cabin.getCabin request.params.id, (err, data) ->
    return reply().redirect '/' if err

    links = [
      {
        title: 'Fakta'
        url: '#fakta'
        glyph: 'list-alt'
      }
      {
        title: 'Kontaktinfo'
        url: '#kontakt'
        glyph: 'comment'
      }
      {
        title: 'Åpningstider'
        url: '#åpningstider'
        glyph: 'time'
      }
      {
        title: 'Senger'
        url: '#senger'
        glyph: 'home'
      }
      {
        title: 'Bilder'
        url: '#bilder'
        glyph: 'picture'
      }
    ]

    reply.view 'cabin',
      site: site
      links: links
      user: request.auth.credentials
      cabin: data
      title: 'Endre hytte'

exports.fetchImage = (id, reply) ->
  cabin.getCabin id, (err, data) ->
    # @TODO(starefossen) code is undefined
    return reply() if err or not data?.bilder?[0]
    cabin.getImage data.bilder[0], (err, data) ->
      # @TODO(starefossen) code is undefined
      return reply() if err or not data?.img?[1]
      stream = request data.img[1].url
      stream.once 'response', reply
      stream.pipe fs.createWriteStream('static/images/cabin/' + id)

exports.getStatistics = (request, reply) ->
  cabin.getCabin request.params.id, (err, cabin) ->
    if /^application\/json/.test request.headers.accept
      stats.getCabinViews cabin.url, (err, data) ->
        reply data
    else
      reply.view 'cabin/statistics',
        site: site
        user: request.auth.credentials
        cabin: cabin
        title: 'Statistikk'
        scripts: ['/static/js/cabin/statistics.js']

