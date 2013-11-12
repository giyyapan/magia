window.Imgs =
  buttonCenter:'button_center.png'
  item:'item.png'
  forestEntry:'forest-entry.jpg'
  forestEntryFloat:'forest-entry-float.png'
  forestEntryFloat2:'forest-entry-float2.png'
  forest2:'forest2.jpg'
  forest3:'forest3.jpg'
  bfForestMain:'bf-forest-main.jpg'
  bfForestFloat:'bf-forest-float.png'
  layer1:'layer1.png'
  layer2:'layer2.png'
  layer3:'layer3.png'
  layer4:'layer4.png'
  layer5:'layer5.png'
  layer6:'layer6.png'
  worldMap:'map.gif'
  demonMap:'demonMap.gif'
  elfMap:'elfMap.gif'
  homeDown:'home_down.jpg'
  homeUp:'home_up.jpg'
window.Sprites =
  test:"test"
  
window.Templates = [
  "start-menu"
  "home-1st-floor"
  "home-2nd-floor"
  "world-map"
  "popup-box"
  "test-menu"
  "area-menu"
  "area-relative-menu"
  "thing-list-item"
  "backpack"
  "battlefield-menu"
  ]
window.Css = []
  
class window.ResourceManager extends Suzaku.EventEmitter
  constructor:()->
    super()
    @imgs = []
    @sprites = []
    @sounds = []
    @templates = []
    @loadedNum = 0
    @totalResNum = null
    @loaded =
      imgs:{}
      sounds:{}
      sprites:{}
      templates:{}
    @imgPath = ""
    @spritePath = ""
    @soundPath = ""
    @tplPath = ""
  useImg:(name,src)->
    #img.name img.src
    @imgs.push name:name,src:src
  useSprite:(name,src)->
    #img.name img.src
    mapSrc = "#{src}.png"
    dataSrc = "#{src}.json"
    @sprites.push name:name,mapSrc:mapSrc,dataSrc:dataSrc
  useSound:(sound)->
    #sound.name sound.src
    @sounds.push sound
  useTemplate:(template)->
    #template name
    @templates.push template
  setPath:(type,path)->
    if typeof path isnt "string"
      return console.error "Illegal Path: #{path} --ResManager" if window.GameConfig.debug
    arr = path.split ''
    if arr[arr.length-1] isnt "/"
      arr.push "/"
    path = arr.join ''
    switch type
      when "img" then @imgPath = path
      when "sound" then @soundPath = path
      when "sprite" then @spritePath = path
      when "template" then @tplPath = path
    #console.log "set #{type} file path:",path if GameConfig.debug
  start:(callback)->
    @on "load",callback if typeof callback is "function"
    @loadedNum = 0
    @totalResNum = @imgs.length + @sprites.length + @sounds.length + @templates.length
    ajaxManager = new Suzaku.AjaxManager
    self = this
    for img in @imgs
      console.log img
      i = new Image()
      i.src = @imgPath+img.src
      i.name = img.name
      i.addEventListener "load",->
        self.loaded.imgs[this.name] = this
        self._resOnload 'img'
    for sprite in @sprites
      i = new Image()
      console.log @spritePath
      i.src = @spritePath+sprite.mapSrc
      i.dataSrc = @spritePath+sprite.dataSrc
      i.name = sprite.name
      i.addEventListener "load",->
        img = this
        $.get img.dataSrc,(data)->
          console.log data
          self.loaded.sprites[img.name] = map:img,data:data
          self._resOnload 'sprite'
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
      console.log "template loaded" if GameConfig.debug
  _resOnload:(type)->
    @loadedNum += 1
    @emit "loadOne",@totalResNum,@loadedNum,type
    if @loadedNum >= @totalResNum
      @emit "load",@loaded

