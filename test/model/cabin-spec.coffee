"use strict"

assert = require 'assert'
ObjectID = require('mongodb').ObjectID

model = require '../../coffee/model/cabin.coffee'
mongo = require '../../coffee/model/mongo.coffee'
cache = require '../../coffee/model/cache.coffee'

describe '#getCabin()', ->
  it 'it get cabin not in cache', (done) ->
    model.getCabin '52407fb375049e56150001bf', (err, cabin) ->
      assert.equal cabin.navn, 'Hallingskeid'
      done()

  it 'should cache cabin in redis', (done) ->
    model.getCabin '52407fb375049e561500008c', (err, cabin) ->
      assert.ifError(err)
      cache.hgetall "cabin:#{cabin._id.toString()}", (err, doc) ->
        assert.equal doc.name, cabin.navn
        assert.equal doc.checksum, cabin.checksum if cabin.checksum
        assert.equal doc.endret, cabin.endret
        assert.equal doc.url, cabin.url
        assert.equal doc.groups, cabin.grupper.join(',') if cabin.grupper
        done()

  it 'should store cabin in database', (done) ->
    model.getCabin '52407fb375049e561500047c', (err, cabin) ->
      assert.ifError(err)
      mongo.db.collection('cabin').findOne _id: cabin._id, (err, doc) ->
        assert.ifError(err)
        assert.deepEqual doc, cabin
        done()

  it 'should get cached cabin', (done) ->
    model.getCabin '52407fb375049e56150002b3', (err, cabin1) ->
      assert.equal cabin1.navn, 'Solrenningen'
      model.getCabin cabin1._id.toString(), (err, cabin2) ->
        assert.ifError(err)
        assert.deepEqual cabin1[key], cabin2[key] for key of cabin1 when key isnt '_id'
        done()

  it 'should cache missing cabin', (done) ->
    id = new ObjectID()
    model.getCabin id.toString(), (err, cabin) ->
      assert.ifError(err)
      assert.equal cabin, null
      cache.hgetall "cabin:#{id.toString()}", (err, c) ->
        assert.ifError(err)
        assert.deepEqual c, status: 'Slettet'
        mongo.db.collection('cabin').findOne _id: id, (err, doc) ->
          assert.ifError(err)
          assert.equal doc, null
          done()

  it 'should correct for missing data in database', (done) ->
    model.getCabin '52407fb375049e5615000304', (err, cabin1) ->
      assert.ifError(err)
      assert.equal cabin1.navn, 'Vending Turisthytte'
      mongo.db.collection('cabin').remove {_id: cabin1._id}, {safe: true}, (err) ->
        assert.ifError(err)
        model.getCabin cabin1._id.toString(), (err, cabin2) ->
          assert.ifError(err)
          assert.deepEqual cabin1[key], cabin2[key] for key of cabin1 when key isnt '_id'
          done()

  it 'should correct for missing data in cache', (done) ->
    model.getCabin '52407fb375049e56150001ad', (err, cabin1) ->
      assert.ifError(err)
      assert.equal cabin1.navn, 'Kvanntjørnsbu'
      cache.del "cabin:#{cabin1._id.toString()}", (err) ->
        assert.ifError(err)
        model.getCabin cabin1._id.toString(), (err, cabin2) ->
          assert.ifError(err)
          assert.deepEqual cabin1[key], cabin2[key] for key of cabin1 when key isnt '_id'
          done()


