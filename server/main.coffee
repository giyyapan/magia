config =
  port:8001
  defaultPathname:"/index.html"
  Expires:
    fileMatch: /|png|jpg|gif|css|js|html|/ig
    maxAge: 60 * 60 * 24 * 365
  MIMETypes:
    "css": "text/css"
    "gif": "image/gif"
    "html": "text/html"
    "ico": "image/x-icon"
    "jpeg": "image/jpeg"
    "jpg": "image/jpeg"
    "js": "text/javascript"
    "json": "application/json"
    "pdf": "application/pdf"
    "png": "image/png"
    "svg": "image/svg+xml"
    "swf": "application/x-shockwave-flash"
    "tiff": "image/tiff"
    "txt": "text/plain"
    "wav": "audio/x-wav"
    "wma": "audio/x-ms-wma"
    "wmv": "video/x-ms-wmv"
    "xml": "text/xml"
    'unknow':"text/plain"
    
Http = require "http"
Path = require "path"
Url = require "url"
Fs = require "fs"
currentPath = __dirname;
console.log currentPath

WriteErr = (err,res)->
  res.writeHead 500,{'Content-Type': 'text/plain'}
  res.end(err)

WriteFile = (realPath,type,res)->
  Fs.readFile realPath, "binary", (err, file)->
    if err then return WriteErr err,res
    else
      #console.log "request:#{realPath} response:200"
      res.writeHead 200,{'Content-Type':config.MIMETypes[type]}
      res.write file,"binary"
      res.end()

MainHandler = (req,res)->
  urldata = Url.parse req.url
  pathname = urldata.pathname
  if pathname is "/" then pathname = config.defaultPathname
  realPath = "#{currentPath}/../local#{pathname}"
  ext = Path.extname(realPath);
  type = if ext then ext.slice(1) else 'unknown'
  Fs.exists realPath,(ans)->
    if ans is no
      res.writeHead 404,{'Content-Type': 'text/plain'}
      res.write "This request URL #{realPath} was not found on this server."
      res.end()
      return
    if ext.match(config.Expires.fileMatch)
      expires = new Date()
      expires.setTime(expires.getTime() + config.Expires.maxAge * 1000)
      res.setHeader "Expires", expires.toUTCString()
      res.setHeader "Cache-Control", "max-age=#{config.Expires.maxAge}"
      Fs.stat realPath, (err, stat)->
        if err then return WriteErr err,res
        lastModified = stat.mtime.toUTCString()
        res.setHeader("Last-Modified", lastModified)
        if lastModified is req.headers['if-modified-since']
            res.writeHead(304, "Not Modified")
            res.end()
        else
          WriteFile realPath,type,res
    else
      WriteFile realPath,type,res
              
server = Http.createServer MainHandler
server.listen config.port

console.log "server running at port:#{config.port}"
