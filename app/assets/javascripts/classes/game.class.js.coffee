delay = window.Peekeweled.helpers.delay
Cell = Peekeweled.classes.Cell
  
class Game
  @GAMES = []
  
  constructor: (@wrapper) ->
    
    @wrapper = @wrapper
    @squares = []
    @user = @wrapper.attr('data-user-id') * 1
    @game = @wrapper.attr('data-game-id') * 1

    score = $("#score_game_"+@game).html()*1

    @getScore = ->
      score
    @incScore = (v) ->
      score += v
      $("#score_game_"+@game).html(score)
      $("#edit_game_"+@game+" [name='game[score]']").each ->
        $(this).val(score)
    
    wrapperHeight =  @wrapper.height()
    @wrapper.find('.square').each (i,s) =>
      @squares.push(new Cell($(s), wrapperHeight, @game))

    #the css rendering is a little slow, wait a beat or you'll see a snap
    delay 0, => @wrapper.addClass("rendered")
    
    @constructor.GAMES.push(@)
    
    $("#start").click =>
      $(this).hide()
      Cell.updateBoard(@game)

    $(window).on 'cells_cleared', (e,game,num,rounds) =>
      @incScore(num*rounds) if game == @game
 
  
window.namespace "Peekeweled.classes", (exports) ->
  exports.Game = Game