window.Imgs =
  buttonCenter:'button_center.png'
  map:'map.gif'
  demonMap:'demonMap.gif'
  elfMap:'elfMap.gif'
  
class window.ResourceManager extends Suzaku.EventEmitter
  constructor:()->
    super()
    @imgs = []
    @sounds = []
    @templates = []
    @loadedNum = 0
    @totalResNum = null
    @loaded =
      imgs:{}
      sounds:{}
      templates:{}
    @imgPath = ""
    @soundPath = ""
    @tplPath = ""
  useImg:(name,src)->
    #img.name img.src
    @imgs.push name:name,src:src
  useSound:(sound)->
    #sound.name sound.src
    @sounds.push sound
  useTemplate:(template)->
    #template name
    @templates.push template
  setPath:(type,path)->
    if typeof path isnt "string"
      return console.error "Illegal Path: #{path} --ResManager" if gameConfig.debug
    arr = path.split ''
    if arr[arr.length-1] isnt "/"
      arr.push "/"
    path = arr.join ''
    switch type
      when "img" then @imgPath = path
      when "sound" then @soundPath = path
      when "template" then @tplPath = path
    #console.log "set #{type} file path:",path if gameConfig.debug
  start:(callback)->
    @on "load",callback if typeof callback is "function"
    @loadedNum = 0
    @totalResNum = @imgs.length + @sounds.length + @templates.length
    ajaxManager = new Suzaku.AjaxManager
    for img in @imgs
      console.log img
      i = new Image()
      i.src = @imgPath+img.src
      i.addEventListener "load",=>
        @loaded.imgs[img.name] = i
        @_resOnload 'img'
    #for sound in @sounds
      #@_resOnload 'sound'
    localDir = @tplPath
    for tplName in @templates
      url = if name.indexOf(".html")>-1 then localDir+tplName else localDir+tplName+".html"
      req = ajaxManager.addGetRequest url,null,(data,textStatus,req)=>
        @loaded.templates[req.Suzaku_tplName] = data
        @_resOnload 'template'
      req.Suzaku_tplName = tplName
    ajaxManager.start =>
      console.log "template loaded" if gameConfig.debug
  _resOnload:(type)->
    @loadedNum += 1
    @emit "loadOne",@totalResNum,@loadedNum,type
    if @loadedNum >= @totalResNum
      @emit "load",@loaded


  
