"use strict"

Report = require 'ga-report'

exports.getCabinViews = (url, cb) ->
  report = new Report
    username: process.env.GA_API_USERNAME
    password: process.env.GA_API_PASSWORD

  name = url.replace 'http://ut.no', ''

  report.once 'ready', ->
    opts =
      'ids': 'ga:17472301'
      'start-date': '2013-01-01'
      'end-date': '2014-01-01'
      'dimensions': 'ga:month'
      'metrics': 'ga:uniquePageviews'
      'filters': 'ga:pagePath=~^' + name
    report.get opts, (err, data) ->
      return cb err if err

      res = []
      for row in data.rows
        res.push month: '2013-' + row[0], views: row[1]

      cb null, res

