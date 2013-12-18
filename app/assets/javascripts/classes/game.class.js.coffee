delay = window.Peekeweled.helpers.delay

class Game
  
  constructor: (@wrapper) ->
    
    @wrapper = @wrapper
    @squares = []
    
    @wrapper.find('.square').each (i,s) =>
      @squares.push(new Peekeweled.classes.Cell($(s)))

    #the css rendering is a little slow, wait a beat or you'll see a snap
    delay 0, => @wrapper.addClass("rendered")
 
 
window.namespace "Peekeweled.classes", (exports) ->
  exports.Game = Game