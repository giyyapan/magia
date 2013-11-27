class window.StoryManager extends EventEmitter
  constructor:(game)->
    @game = game
    @storyData = Res.tpls["story"]
    @storys = {}
    @initStoryData()
  initStoryData:->
    console.log "hahahahahah"
    lines = @storyData.split "\n"
    currentArr = []
    for l in lines
      if l.indexOf("***") is 0
        name = l.replace("***","")
        @currentArr = @storys[name] = []
        continue
      @currentArr.push l
    console.log @storys
  showStory:(name)->
    console.log "show story",name
