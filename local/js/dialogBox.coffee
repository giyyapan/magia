class window.DialogBox extends Menu
  constructor:(alwaysontop=false)->
    super Res.tpls['dialog-box']
    @onshow = false
    @displayInterval = null
    @displayLock = false
    if alwaysontop then @J.addClass "top"
    @UI['content-wrapper'].onclick = =>
      if @displayLock
        @endDisplay()
      else
        @UI['continue-hint'].J.fadeOut "fast"
        @emit "next"
  setCharacter:(name,position)->
    console.log "set character"
  setSpeaker:(speaker)->
    return if not speaker
    @UI.speaker.J.text "#{speaker}:"
  endDisplay:(nostop)->
    window.clearInterval @displayInterval
    @displayLock = false
    text = @currentDisplayData.text
    text = text.replace /\|/g,"</br>"
    text = text.replace /`/g,""
    @UI.text.innerHTML = text
    if nostop then @emit "next"
    else @UI['continue-hint'].J.fadeIn "fast"
  display:(data,callback)->
    console.log data.text
    return if not data.text or @displayLock
    if not @onshow
      @show => @display(data,callback)
    if data.nostop is undefined
      data.nostop = false
    @setSpeaker data.speaker
    @UI['continue-hint'].J.fadeOut "fast"
    @once "next",callback if callback
    @displayLock = true
    @currentDisplayData = data
    arr = data.text.split ""
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
            delay = 3 if index isnt (arr.length - 1)
            c = arr[index]
          when "!","！","。"
            delay = 3 if index isnt (arr.length - 1)
            c = arr[index]
          else c = arr[index]
        @UI.text.innerHTML += c
        index += 1
      else
        @endDisplay data.nostop
      ),60
  show:(callback)->
    #@UILayer.J.find("menu").fadeOut "fast"
    if @onshow
      callback() if callback
      return
    @onshow = true
    @J.hide()
    @appendTo @UILayer.dom
    @J.fadeIn "fast",=>
      callback() if callback
  hide:(callback)->
    @onshow = false
    @css3Animate.call @UI['content-wrapper'],"animate-pophide",=>
      try @remove()
      callback() if callback
    
    
