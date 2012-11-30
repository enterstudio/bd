request = require 'request'
async = require 'async'
qs = require 'qs'

ignoredHeaders = ["cookie","referer","host","connection","accept-encoding"]
defaultCookies =
  get: (id, cb) -> cb()
  set: (id, cookies, cb) -> cb()

module.exports =
  createProxy: (opt={}) ->
    opt.cookies ?= defaultCookies

    proxy = (req, res, next) ->
      proxy._middle 'processRequest', [req], (err) ->
        return res.send 500, err if err?

        url = req.query.surl
        [url, query] = url.split('?')
        query = qs.parse query if query?
        id = req.params.id
        host = req.headers.host

        opt.cookies.get id, (err, cookie) ->
          return res.send 500, err if err?
          jar = request.jar()
          jar.add cookie if cookie?

          head = {}
          head[k]=v for k,v of req.headers when not (k.toLowerCase() in ignoredHeaders)

          ropt =
            headers: head
            method: req.method
            qs: query
            jar: jar
            url: url
            body: req.body

          request ropt, (err, remoteRes, body) ->
            return res.send 500, err if err?

            ncookies = jar.cookieString ropt
            opt.cookies.set id, ncookies, (err) ->
              return res.send 500, err if err?

              remoteRes.body = body
              proxy._middle 'processResponse', [req,remoteRes], (err) ->
                return res.send 500, err if err?
                res
                  .status(remoteRes.statusCode)
                  .set(remoteRes.headers)
                  .send remoteRes.body

    proxy.stack = []
    proxy.use = (ns, fn) ->
      proxy.stack.push {ns:ns,handle:fn}

    proxy._middle = (ns, args, cb) ->
      return cb() if proxy.stack.length is 0
      run = (middle, done) => 
        return done() if middle.ns isnt ns
        middle.handle args..., done
      async.forEachSeries proxy.stack, run, cb
      return

    return proxy