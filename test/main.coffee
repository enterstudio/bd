moxy = require '../'
should = require 'should'
require 'mocha'

request = require 'request'
express = require 'express'

describe 'moxy', ->
  describe 'createProxy()', ->
    it 'should return function', (done) ->
      fn = moxy.createProxy()
      type = typeof fn
      type.should.equal 'function'
      done()

    it 'should proxy requests', (done) ->
      proxy = moxy.createProxy()

      app = express()
      app.all '/proxy/:id', proxy
      app.listen 8008

      app2 = express()
      app2.get '/test', (req, res) ->
        should.exist req.header('Client-Header')
        req.header('Client-Header').should.equal 'wot'
        should.exist req.query.wat
        req.query.wat.should.equal 'dood'
        res
          .status(200)
          .set('Custom-Header', 'test')
          .send 'hello world'

      app2.listen 8009

      opt =
        headers:
          'Client-Header': 'wot'

      request "http://localhost:8008/proxy/test/?surl=http://localhost:8009/test?wat=dood", opt, (err, res, body) ->
        should.not.exist err, 'res error'
        should.exist res, 'res'
        should.exist body, 'body'
        should.exist res.headers['custom-header']
        res.statusCode.should.equal 200
        res.headers['custom-header'].should.equal 'test'
        body.should.equal 'hello world'
        done()

  describe 'use()', ->
    it 'should work', (done) ->
      fn = moxy.createProxy()
      fn.use 'test', (hello, next) ->
        hello.world.push 0
        next()

      fn.use 'test', (hello, next) ->
        hello.world.push 1
        next()

      mock = world: []

      fn._middle 'test', [mock], (err) ->
        should.not.exist err
        mock.world.should.eql [0,1]
        done()

    it 'should halt on error', (done) ->
      fn = moxy.createProxy()
      fn.use 'test', (hello, next) ->
        hello.world.push 0
        next()

      fn.use 'test', (hello, next) -> next 'error'

      fn.use 'test', (hello, next) ->
        hello.world.push 1
        next()

      mock = world: []

      fn._middle 'test', [mock], (err) ->
        should.exist err
        mock.world.should.eql [0]
        done()