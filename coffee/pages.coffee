"use strict"

fs = require 'fs'
path = require 'path'

Pages = (dirPath) ->
  @_dirPath = dirPath
  @_cache = {}
  @loadPagesIntoCache()

Pages.prototype.loadPagesIntoCache = ->
  fs.readdirSync(@_dirPath).forEach (file) =>
    @_cache[file] = @loadPageFile(file) if file[0] isnt '.'

Pages.prototype.getAll = -> @_cache

Pages.prototype.getPage = (name) -> @_cache[name]

Pages.prototype.savePage = (name, contents) ->
  name = path.normalize(name)
  fs.writeFileSync(path.join(@_dirPath, name), contents)
  @_cache[name] = name: name, contents: contents
  return

Pages.prototype.loadPageFile = (file) ->
  contents = fs.readFileSync(path.join(@_dirPath, file))

  return name: file, contents: contents.toString()

module.exports = new Pages(path.join(__dirname, '../_pages'))

