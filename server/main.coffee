config =
  port:8001
  defaultPathname:"/index.html"
  Expires:
    fileMatch: /|png|jpg|gif|css|js|html|ogg|mp3|/ig
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
    "ogg": "audio/ogg"
    "mp3": "audio/mp3"
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

ParseRange = (str, size) ->
    console.log "fuck"
    if str.indexOf(",") isnt -1
      return
    range = str.split("-")
    start = parseInt(range[0], 10)
    end = parseInt(range[1], 10)
    if isNaN end
      end = size - 1
    if isNaN start
      start = size - end - 1
    console.log start,end
    if isNaN(start) or isNaN(end) or start > end or end > size
      return false
    return start: start,end: end

WriteFile = (req,realPath,type,res)->
  res.setHeader 'Content-Type',config.MIMETypes[type]
  if req.headers.range then Fs.stat realPath,(err,stats)->
    if err 
      return WriteErr err,res
    range = ParseRange(req.headers["range"], stats.size)
    console.log range if range
    if range
      res.setHeader("Content-Range", "bytes " + range.start + "-" + range.end + "/" + stats.size)
      res.setHeader("Content-Length", (range.end - range.start + 1))
      raw = Fs.createReadStream realPath,{start: 0,end: range.end}
      res.writeHead 206,"Partial Content"
      raw.pipe res
    else 
      res.removeHeader("Content-Length")
      res.writeHead(416, "req Range Not Satisfiable")
      res.end()   
  else 
    raw = Fs.createReadStream(realPath)
    res.writeHead 200,"Ok",
    raw.pipe res

MainHandler = (req,res)->
  urldata = Url.parse req.url
  pathname = urldata.pathname
  if pathname is "/" then pathname = config.defaultPathname
  realPath = "#{currentPath}/../local#{pathname}"
  ext = Path.extname(realPath);
  type = if ext then ext.slice(1) else 'unknown'
  Fs.exists realPath,(ans)->
    if ans is no
      console.log realPath
      res.writeHead 404,{'Content-Type': 'text/plain'}
      res.end "404"
      return true
    if true or ext.match(config.Expires.fileMatch)
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
          WriteFile req,realPath,type,res
    else
      WriteFile req,realPath,type,res
              
server = Http.createServer MainHandler
server.listen config.port

console.log "server running at port:#{config.port}"
