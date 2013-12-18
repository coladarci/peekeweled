delay = window.Peekeweled.helpers.delay
Cell = Peekeweled.classes.Cell
  
class Game
  @GAMES = []
  
  constructor: (@wrapper) ->
    
    @wrapper = @wrapper
    @squares = []
    @user = @wrapper.attr('data-user-id') * 1
    
    @wrapper.find('.square').each (i,s) =>
      @squares.push(new Cell($(s)))

    #the css rendering is a little slow, wait a beat or you'll see a snap
    delay 0, => @wrapper.addClass("rendered")
    
    @constructor.GAMES.push(@)
 
  
window.namespace "Peekeweled.classes", (exports) ->
  exports.Game = Game