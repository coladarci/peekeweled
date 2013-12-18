delay = window.Peekeweled.helpers.delay
Cell = Peekeweled.classes.Cell
  
class Game
  @GAMES = []
  
  constructor: (@wrapper) ->
    
    @wrapper = @wrapper
    @squares = []
    @user = @wrapper.attr('data-user-id') * 1
    
    score = 0

    @getScore = ->
      score
    @incScore = (v) ->
      score += v
      $("#score").html(score)
    
    wrapperHeight =  @wrapper.height()
    @wrapper.find('.square').each (i,s) =>
      @squares.push(new Cell($(s), wrapperHeight))

    #the css rendering is a little slow, wait a beat or you'll see a snap
    delay 0, => @wrapper.addClass("rendered")
    
    @constructor.GAMES.push(@)
    
    delay 500, -> 
      #Cell.updateBoard()
    
    $(window).on 'cells_cleared', (e,num) =>
      @incScore(num)
 
  
window.namespace "Peekeweled.classes", (exports) ->
  exports.Game = Game