delay = window.Peekeweled.helpers.delay
Cell = Peekeweled.classes.Cell
  
class Game
  @GAMES = []
  
  @SOCKET = io.connect("http://lady.local:8081", { secure: false, reconnect: true })
  
  @SOCKET.on 'click', (d) ->
    console.log d
    el = $("[data-game-id='"+d.game+"'] [data-col='"+d.col+"'][data-row='"+d.row+"']")
    el.data('obj').click();
  
  constructor: (@wrapper) ->
    
    @wrapper = @wrapper
    @squares = []
    @user = @wrapper.attr('data-user-id') * 1
    @game = @wrapper.attr('data-game-id') * 1
    @socketRoom = '37-38'

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
      $(s).on 
          click: (e) =>
              data = {game: @game, col: $(e.target).attr('data-col'),row: $(e.target).attr('data-row') }
              @constructor.SOCKET.emit('click', data)
              false
              
      @squares.push(new Cell($(s), wrapperHeight, @game))

      

    #the css rendering is a little slow, wait a beat or you'll see a snap
    delay 0, => @wrapper.addClass("rendered")
    
    @constructor.GAMES.push(@)
    
    $("#start").click =>
      $(this).hide()
      Cell.updateBoard(@game)

    $(window).on 'cells_cleared', (e,game,num,rounds) =>
      @incScore(num*rounds) if game == @game
    
    
    @constructor.SOCKET.emit('set room', @socketRoom)
    
  
window.namespace "Peekeweled.classes", (exports) ->
  exports.Game = Game