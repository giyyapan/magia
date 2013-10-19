conf =
  debug:2 #0 to turn debug off, 1 for basic debug, and 2 for full debug
  showFPS:true
  frameRate:60
  canvasId:'gameCanvas'
  script:[
    'js/jquery.min.js'
    'js/suzaku.js'
    'js/base.js'
    'js/utils.js'
    
    'js/player.js'
    'js/item.js'
    'js/monster.js'
    
    'js/mainMenu.js'
    'js/home.js'
    'js/worldMap.js'
    'js/town.js'
    'js/area.js'
    
    'js/resource.js'
    'js/magia.js'
    ]
    
if not document.createElement('canvas').getContext
  dom = document.createElement('div')
  dom.innerHTML = '<h2>Your browser does not support HTML5 canvas!</h2>' +
    '<p>Google Chrome is a browser that combines a minimal design with sophisticated technology to make the web faster, safer, and easier.Click the logo to download.</p>' +
    '<a href="http://www.google.com/chrome" target="_blank"><img src="http://www.google.com/intl/zh-CN/chrome/assets/common/images/chrome_logo_2x.png" border="0"/></a>'
  p = document.getElementById(conf.canvasId).parentNode
  p.style.background = 'none'
  p.style.border = 'none'
  p.insertBefore dom
  
  document.body.style.background = '#ffffff'

window.addEventListener 'DOMContentLoaded',->
  this.removeEventListener('DOMContentLoaded', arguments.callee, false);
  for script in conf.script
    s = d.createElement('script');
    s.src = script 
    document.body.appendChild(s);
  window.gameConfig = conf
        
