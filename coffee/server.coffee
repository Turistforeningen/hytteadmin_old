"use strict"

path   = require 'path'
Server = require('hapi').Server
pages  = require './pages'

internals = {}

view = (viewName) ->
  (request, reply) ->
    reply.view(viewName, { title: viewName })

getPages = (request, reply) ->
  reply.view('index', { pages: Object.keys(pages.getAll()), title: 'All pages' })

getPage = (request, reply) ->
  reply.view('page', { page: pages.getPage(request.params.page), title: request.params.page })

createPage = (request, reply) ->
  pages.savePage(request.payload.name, request.payload.contents)
  reply.view('page', { page: pages.getPage(request.payload.name), title: 'Create page' })

showEditForm = (request, reply) ->
  reply.view('edit', { page: pages.getPage(request.params.page), title: 'Edit: ' + request.params.page })

updatePage = (request, reply) ->
  pages.savePage(request.params.page, request.payload.contents)
  reply.view('page', { page: pages.getPage(request.params.page), title: request.params.page })

internals.main = () ->
  options = {
    views: {
      engines: { html: 'handlebars' },
      path: path.join(__dirname, '../views'),
      layout: true,
      partialsPath: path.join(__dirname, '../views', 'partials')
    },
    state: {
      cookies: {
        failAction: 'ignore'
      }
    }
  }

  server = new Server(8080, options)
  server.route({ method: 'GET', path: '/', handler: getPages })
  server.route({ method: 'GET', path: '/pages/{page}', handler: getPage })
  server.route({ method: 'GET', path: '/create', handler: view('create') })
  server.route({ method: 'POST', path: '/create', handler: createPage })
  server.route({ method: 'GET', path: '/pages/{page}/edit', handler: showEditForm })
  server.route({ method: 'POST', path: '/pages/{page}/edit', handler: updatePage })
  server.start()

internals.main()

