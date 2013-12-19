"use strict"

path = require 'path'
site = require '../model/config'

exports.getIndex = (request, reply) ->
  return reply.redirect '/login' if not request.auth.isAuthenticated
  reply.redirect '/liste'

exports.getStatic =
  directory:
    path: path.join(__dirname, '../', '../', 'static')
    redirectToSlash: true

