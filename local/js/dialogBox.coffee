class DialogBox extends Menu
  constructor:->
    super Res.tpls['dialog-box']
    @displayInterval = null
    @displayLock = false
    @UI['content-wrapper'].onclick = =>
      if display
        @endDisplay()
      else
        @emit "next"
  setCharacter:(name,position)->
    console.log "set character"
  endDisplay:->
    window.clearInterval @displayInterval
    @displayLock = false
    @UI.text.innerHTML = @currentDisplayData.text
  display:(data,callback)->
    return if @displayLock
    @once "next",callback
    @displayLock = true
    @currentDisplayData = data
    return if not data.text
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
        index += 1
        switch arr[index]
          when "|" then c = "</br>"
          when "!","！","。"
            delay = 3
            c = arr[index]
          else c = arr[index]
        @UI.text.innerHTML += arr[index]
      else
        @endDisplay()
      ),50
  show:(callback)->
    @UILayer.J.find("menu").fadeOut "fast",=>
      @J.hide()
      @appendTo @UILayer.dom
      @J.fadeIn "fast",->
        callback() if callback
  hide:(callback)->
    @J.fadeOut "fast",=>
      @UILayer.J.find("menu").fadeIn "fast"
      @remove()
      callback() if callback
    
    
