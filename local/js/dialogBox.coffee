class DialogCharacter extends Widget
  constructor:(tpl,name,data)->
    super tpl
    @name = name
    img = Res.imgs[data.dialogPic]
    @UI.img.src = img.src if img
    @position = null
  useEffect:(name)->
    switch name
      when "none"
        @UI.img.J.removeClass()
      when "shadow"
        @UI.img.J.addClass "shadow"
  getOut:(type)->
    @J.fadeOut "fast",=>
      @remove()
  getIn:(position)->
    @position = position
    if not position
      if @name is "player" then position = "left"
      else position = "right"
    @J.addClass "left","right","center"
    @J.fadeIn "fast"
    switch position
      when "left","l"
        @J.addClass "left"
      when "right","r"
        @J.addClass "right"
      when "center","c"
        @J.addClass "center"
        
class window.DialogBox extends Menu
  constructor:(game,alwaysontop=false)->
    super Res.tpls['dialog-box']
    @game = game
    @db = game.db
    @onshow = false
    @displayInterval = null
    @displayLock = false
    @characters = {}
    @currentCharacter = null
    if alwaysontop then @J.addClass "top"
    @UI['content-wrapper'].onclick = =>
      if @displayLock
        @endDisplay()
      else
        @UI['continue-hint'].J.fadeOut "fast"
        @currentCharacter.J.removeClass "speaking" if @currentCharacter
        @emit "next"
  setCharacter:(name,options)->
    console.log "set character",name,options
    data = @db.characters.get name
    dspName = data.name
    @currentCharacter = @characters[name]
    for type,value of options
      switch type
        when "in"
          if not @characters[name]
            @characters[name] = new DialogCharacter @UI['character-tpl'].innerHTML,name,data
          @currentCharacter = @characters[name]
          @currentCharacter.getIn value 
          @currentCharacter.appendTo @UI['character-section']
        when "out"
          if not @currentCharacter then return console.error "no such character",name
          @currentCharacter.getOut value
          delete @characters[name]
          return
        when "effect"
          if not @currentCharacter then return console.error "no such character",name
          @currentCharacter.useEffect value
          if value is "shadow"
            dspName = "???"
    @setSpeaker dspName
  setSpeaker:(speaker)->
    if speaker
      @UI.speaker.J.text "#{speaker}:"
    else
      @UI.speaker.J.text " "
  endDisplay:()->
    window.clearInterval @displayInterval
    @displayLock = false
    text = @currentDisplayData.text
    text = text.replace /\|/g,"</br>"
    text = text.replace /`/g,""
    @UI.text.innerHTML = text
    if @nostop then @emit "next"
    else @UI['continue-hint'].J.fadeIn "fast"
  display:(data,callback)->
    if @displayLock then @endDisplay()
    return if not data.text
    if not @onshow
      @show => @display(data,callback)
      return
    #console.error "dialogBox Display:",data.text
    if data.nostop then @nostop = true
    else @nostop = false
    @setSpeaker data.speaker
    @UI['continue-hint'].J.fadeOut "fast"
    @once "next",callback if callback
    @displayLock = true
    @currentDisplayData = data
    if data.text.indexOf("!!") is 0 or data.text.indexOf("！！") is 0
      @css3Animate "animate-pop"
      @currentCharacter.css3Animate "animate-pop" if @currentCharacter
      data.text = data.text.replace("!!","").replace("！！","")
    if @currentCharacter
      @currentCharacter.J.addClass "speaking"
    @setDisplayInterval data.text
  setDisplayInterval:(text)->
    arr = text.split ""
    index = 0
    @UI.text.innerHTML = ""
    delay = 0
    currentDelay = 0
    @displayInterval = window.setInterval (=>
      if delay and currentDelay < delay
        return currentDelay += 1
      delay = 0
      currentDelay = 0
      if index < arr.length
        if index is arr.length - 1 then delay = 3
        switch arr[index]
          when "|","|" then c = "</br>"
          when "`" then c = ""
          when ",","，"
            delay = 2 if index isnt (arr.length - 1)
            c = arr[index]
          when "!","！","。"
            delay = 2 if index isnt (arr.length - 1)
            c = arr[index]
          else c = arr[index]
        @UI.text.innerHTML += c
        index += 1
      else
        @endDisplay()
      ),60
  show:(callback)->
    #@UILayer.J.find("menu").fadeOut "fast"
    if @onshow
      callback() if callback
      return
    @onshow = true
    @J.hide()
    @J.find(".character-box").hide()
    @appendTo @UILayer.dom
    @J.find(".character-box").fadeIn 200
    @J.fadeIn "fast",=>
      callback() if callback
  hide:(callback)->
    return if not @onshow
    @onshow = false
    @J.find(".character-box").fadeOut 200
    @css3Animate.call @UI['content-wrapper'],"animate-pophide",=>
      try @remove()
      callback() if callback
    
    
