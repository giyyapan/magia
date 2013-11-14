conf =
  port:8001
  defaultPathname:"/index.html"
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
currentPath = Fs.realpathSync('.');
console.log currentPath

MainHandler = (req,res)->
  urldata = Url.parse req.url
  pathname = urldata.pathname
  if pathname is "/" then pathname = conf.defaultPathname
  realPath = "#{currentPath}/../local#{pathname}"
  ext = Path.extname(realPath);
  type = if ext then ext.slice(1) else 'unknown'
  Path.exists realPath,(ans)->
    if ans is yes
      Fs.readFile realPath, "binary", (err, file)->
        if err
          res.writeHead 500,{'Content-Type': 'text/plain'}
          res.end(err)
        else
          console.log "request:#{pathname} response:200"
          res.writeHead 200,{'Content-Type':conf.MIMETypes[type]}
          res.write file,"binary"
          res.end()
    else
      res.writeHead 404,{'Content-Type': 'text/plain'}
      res.write "This request URL #{realPath} was not found on this server."
      res.end()
            
server = Http.createServer MainHandler
server.listen conf.port

console.log "server running at port:#{conf.port}"

  
