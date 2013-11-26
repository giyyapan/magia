class window.DialogBox extends Menu
  constructor:(alwaysontop=false)->
    super Res.tpls['dialog-box']
    @displayInterval = null
    @displayLock = false
    if alwaysontop then @J.addClass "top"
    @UI['content-wrapper'].onclick = =>
      if @displayLock
        @endDisplay()
      else
        @emit "next"
  setCharacter:(name,position)->
    console.log "set character"
  setSpeaker:(speaker)->
    return if not speaker
    @UI.speaker.J.text "#{speaker}:"
  endDisplay:(nostop)->
    window.clearInterval @displayInterval
    @displayLock = false
    @UI.text.innerHTML = @currentDisplayData.text
    if nostop then @emit "next"
    else @UI['continue-hint'].J.show()
  display:(data,callback)->
    console.log data.text
    return if not data.text or @displayLock
    if data.nostop is undefined
      data.nostop = false
    @setSpeaker data.speaker
    @UI['continue-hint'].J.hide()
    @once "next",callback
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
          when "|" then c = "</br>"
          when "`" then c = ""
          when ",","，"
            delay = 3 if index isnt (arr.length - 1)
            c = arr[index]
          when "!","！","。"
            delay = 3 if index isnt (arr.length - 1)
            c = arr[index]
          else c = arr[index]
        @UI.text.innerHTML += arr[index]
        index += 1
      else
        @endDisplay data.nostop
      ),80
  show:(callback)->
    #@UILayer.J.find("menu").fadeOut "fast"
    @J.hide()
    @appendTo @UILayer.dom
    @J.fadeIn "fast",=>
      callback() if callback
  hide:(callback)->
    @css3Animate.call @UI['content-wrapper'],"animate-pophide",=>
      try @remove()
      callback() if callback
    
    
