// Generated by CoffeeScript 1.6.3
(function() {
  var body, conf, dom;

  conf = {
    debug: 2,
    noSound: true,
    showFPS: true,
    frameRate: 60,
    canvasId: "#gameCanvas",
    UILayerId: "#UILayer",
    screen: {
      width: 1280,
      height: 720
    },
    speedValue: {
      fast: 200,
      normal: 350,
      slow: 600
    }
  };

  if (!document.createElement('canvas').getContext) {
    dom = document.createElement('div');
    dom.innerHTML = '<h2>Your browser does not support HTML5 canvas!</h2>' + '<p>Google Chrome is a browser that combines a minimal design with sophisticated technology to make the web faster, safer, and easier.Click the logo to download.</p>' + '<a href="http://www.google.com/chrome" target="_blank"><img src="http://www.google.com/intl/zh-CN/chrome/assets/common/images/chrome_logo_2x.png" border="0"/></a>';
    body = document.body;
    body.style.background = 'none';
    body.style.border = 'none';
    body.style.height = "" + conf.screen.height + "px";
    body.insertBefore(dom);
  }

  window.GameConfig = conf;

  if (!conf.debug) {
    window.console.log = (function() {});
  }

}).call(this);
