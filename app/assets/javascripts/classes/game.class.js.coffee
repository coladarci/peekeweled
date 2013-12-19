delay = window.Peekeweled.helpers.delay
Cell = Peekeweled.classes.Cell

###
  The Game class handles the initializing of new games, web sockets and scoring.

  TODO: A lot of game funtionality has ended up in the Cell class in the form of Static Class Methods.
        This isn't the worst thing in the world, but I've found that all of those methods need a GameId to
        Function properly, so it'd be considerably better to move those into instance methods of the game.

        This is actually a pretty trivial move..
###
  
class Game

  ###
    Web sockets are shared between instances of games. 
    - initialize them and whenever we get a click event, simply pass that click on to the object
      associate with the element clicked. Easy stuff!
  ###
  @SOCKET = io.connect("http://peekeweled.nodejitsu.com:80", { secure: false, reconnect: true })
  @SOCKET.on 'click', (d) ->
    el = $("[data-game-id='"+d.game+"'] [data-col='"+d.col+"'][data-row='"+d.row+"']")
    el.data('obj').click();
  #work in progress-  I'd like to detect when both people have arrived in a Dual so the game can start and players can be notified..
  @SOCKET.on 'ready', (d) ->
    console.log(d, 'is ready')
  
  
  constructor: (@wrapper) ->
    
    #A game is initialized with a reference to the wrapper of the game. This ensures to ability to have multigames going at once..
    @wrapper = @wrapper
    @squares = []
    @user = @wrapper.attr('data-user-id') * 1
    @game = @wrapper.attr('data-game-id') * 1

    ###
      Scoring:
         I'm starting the score off based on what is in the field when the server draws the game. On the service this seems 
         slopppy, but actually relatively secure in that users can't monkey with this since it's private and happens when the page is loaded and never again.
    
         The major vulnerability here is that people can trigger a "cells_cleared" event if they are clever.
         The fix to this is to keep those methods private, but as long as a lot of my logic is in the Cell class, I can't easil
         Get to my game instance.
    
         When the logic is ported over to the Game class as mentioned at the top, these methods can stay private.
    ###

    score = $("#score_game_"+@game).html()*1

    @getScore = ->
      score
    @incScore = (v) ->
      score += v
      $("#score_game_"+@game).html(score)
      $("#edit_game_"+@game+" [name='game[score]']").each ->
        $(this).val(score)
    
    
    ###
      Run through ever square in the wrapper:
        - first bind a click for websockets
        - second inititialize a new Cell
          - I'm saving a reference to the cell in the game class as a start to move the logic into the game
    ###
    @wrapper.find('.square').each (i,s) =>
      $(s).on 
          click: (e) =>
              data = {game: @game, col: $(e.target).attr('data-col'),row: $(e.target).attr('data-row') }
              @constructor.SOCKET.emit('click', data)
              false
              
      @squares.push(new Cell($(s), @wrapper.height(), @game))

      

    #the css rendering is a little slow, wait a beat or you'll see a snap
    delay 0, => @wrapper.addClass("rendered")
    
    #Saving a reference to the game
    #@constructor.GAMES.push(@)
    
    #Not in use yet, but will be helpful in dual mode to signal that a player is ready to start
    ###
        $("#start").click =>
          $(this).hide()
          Cell.updateBoard(@game)
    ###
    
    ###
    This is what should be private - Cells trigger this event when cells are cleared. 
    Love the abstraction, hate the security implications
    ###

    $(window).on 'cells_cleared', (e,game,num,rounds) =>
      @incScore(num*rounds) if game == @game
    
    
    ###
      And finally, let the web sockets know we are good to go.
      This needs to move to it's own class as it's firing for both games in Dual mode - again simple fix
    ###
    @constructor.SOCKET.emit('set room', window.location.href.split('/games/')[1].split("#")[0])
    @constructor.SOCKET.emit('ready', @game)
    
  
window.namespace "Peekeweled.classes", (exports) ->
  exports.Game = Game