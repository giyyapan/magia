class window.StoryManager extends EventEmitter
  constructor:->
    @storyData = Res.tpls["story"]
    @storys = {}
    @initStoryData()
  initStoryData:->
    console.log "init story data"
  showStory:(name)->
    console.log "show story",name
