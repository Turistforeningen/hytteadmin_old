"use strict"

request = require 'request'

data =
  '52407fb375049e5615000034': 'Holmaskjer'
  '52407fb375049e5615000074': 'Alexander G.'
  '52407fb375049e561500008c': 'Fonnabu'
  '52407fb375049e561500008f': 'Kalvedalshytta'
  '52407fb375049e56150001fd': 'Breidablikk'
  '52407fb375049e561500047c': 'Hadlaskard'
  '52407fb375049e5615000118': 'Selhamar'
  '52407fb375049e56150001a7': 'Mosdalsbu'
  '52407fb375049e56150001f7': 'Høgabu'
  '52407fb375049e561500038d': 'Norddalshytten'
  '52407fb375049e5615000469': 'Skavlabu'
  '52407fb375049e56150003a3': 'Træet gård'
  '52407fb375049e5615000218': 'Vatnane'
  '52407fb375049e56150001ad': 'Kvanntjørnsbu'
  '52407fb375049e56150001bf': 'Hallingskeid'
  '52407fb375049e5615000296': 'Vardadalsbu'
  '52407fb375049e56150002b3': 'Solrenningen'
  '52407fb375049e561500024e': 'Stavali'
  '52407fb375049e5615000304': 'Vending Thytte'
  '52407fb375049e5615000460': 'Åsedalen'
  '52407fb375049e5615000346': 'Kiellandbu'
  '52407fb375049e5615000158': 'Breidablik'
  '52407fb375049e56150002e8': 'Skålatårnet'

exports.getCabins = (group) ->
  res = []
  for _id, navn of data
    res.push
      _id: _id
      navn: navn
      bilde: '/static/images/hytte.png'
  res

exports.getCabin = (id, cb) ->
  url = "http://api.nasjonalturbase.no/steder/#{id}?api_key=dnt"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body

exports.getImage = (id, cb) ->
  url = "http://api.nasjonalturbase.no/bilder/#{id}?api_key=dnt"
  request url: url, json: true, (err, res, body) ->
    if err or res.statusCode isnt 200 or not body
      return cb new Error('Not Found')

    cb null, body

