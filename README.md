![status](https://secure.travis-ci.org/wearefractal/moxy.png?branch=master)

## Information

<table>
<tr> 
<td>Package</td><td>moxy</td>
</tr>
<tr>
<td>Description</td>
<td>Simple and configurable HTTP injection/intercept proxy</td>
</tr>
<tr>
<td>Node Version</td>
<td>>= 0.4</td>
</tr>
</table>

## Usage

```coffee-script
moxy = require 'moxy'
express = require 'express'

app = express()
app.use express.bodyParser()
app.use express.methodOverride()

proxy = moxy.createProxy()
app.all '/proxy/:id/:url', proxy

proxy.use 'processRequest', (req, next) ->
  # req = client request to proxy

proxy.use 'processResponse', (req, res, next) ->
  # req = client request to proxy
  # res = response from requested server


app.listen 8080
```

The id you use determines which set of cookies to use. This allows multiple users to retain cookies between requests.

The proxy supports GET/POST/PUT/DELETE

Example request for http://www.google.com/imghp?hl=en&tab=wi&authuser=0

```
GET localhost:8080/proxy/main/www.google.com/imghp?hl=en&tab=wi&authuser=0
```

## Examples

You can view more examples in the [example folder.](https://github.com/wearefractal/moxy/tree/master/examples)

## LICENSE

(MIT License)

Copyright (c) 2012 Fractal <contact@wearefractal.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
