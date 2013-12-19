delay = window.Peekeweled.helpers.delay
  
class Cell
  
  #we store all cells here so we are hitting the dom as little as possible
  @CELLS = {}
  #store upcoming cells to ensure in Dual mode both people have the same board (assuming they make the same moves)
  @BANK = {}
  
  constructor: ($el, $wrapperHeight, gameId) ->
    ###
      Common trend - nearly every method takes a GameId - 
      Only glaring architectural disaster. Anything requiring a GameId should be moved into the game class.
      Cells should (dumb) and only be responsible for:
        - drawing
        - moving
        - destroying
    
      The reason it's this way is because these GameIds only came around when I added Dual Mode where
      I need two games at once.
    ###

    @el = $el 
    @game = gameId
    
    ###
      Cache the cell size and wrapper height; used in calculations
    ###
    if (!@constructor.CELL_SIZE )
      @constructor.CELL_SIZE = @el.width()
    if (!@constructor.WRAPPER_HEIGHT )
      @constructor.WRAPPER_HEIGHT= $wrapperHeight
    
    #run through floated grid and "lock in" position absolutely
    #this coculd be done other ways but this allows the potential for using floats to our advantage for fluidness
    offset = $el.position()
    bottom = $wrapperHeight - (offset.top + @constructor.CELL_SIZE)
    $el.css({
      bottom : bottom,
      left: offset.left
    }).attr({
      "data-bottom": bottom,
      "data-left": offset.left 
    })

    #cool trick to link the instance to the dom element.
    @el.data('obj', @)
        
    #simply pass the click event on
    @el.on 
        click: (e) =>
            @click()
            false
    
    #finally, store the reference of the cell
    if !@constructor.CELLS[gameId] 
      @constructor.CELLS[gameId] = []

    @constructor.CELLS[gameId].push(@)
    

  
  
  ###
    Whole crap load of setters and getters
    TODO: setRow and setCol now call the more granular methods, those granular methods can either be combined
    or made private. Easy, but needs careful refactoring.
    The goal is to never have to do anything other than @setRow(1) or @setCol(2) and have the css change accordingly
  ###
  getBottom: () ->
    @el.attr('data-bottom')*1
  getLeft: () ->
    @el.attr('data-left')*1
  setBottom: (v) ->
    @el.attr('data-bottom',v)
    @el.css('bottom', v + "px")
  setLeft: (v) ->
    @el.attr('data-left',v)
    @el.css('left', v + "px")
  getCol: ->
    @el.attr('data-col')*1
  setCol: (v) ->
    @setLeft(@constructor.CELL_SIZE * (v-1))
    @el.attr('data-col', v)
  getRow: ->
    @el.attr('data-row')*1
  setRow: (v) ->
    @setBottom(@constructor.WRAPPER_HEIGHT - (@constructor.CELL_SIZE * v))
    @el.attr('data-row', v)
  isActive: ->
    @active == true
  setActive: (v) ->
    @active = v
    if v
      @el.addClass('active')
    else
      @el.removeClass('active')
  
  getId: ->
    @el.attr('data-num')*1
  getType: ->
    @el.attr('data-type')
    
  isExploded: ->
    @exploded == true
  explode: ->
    @el.addClass('exploded')
    @exploded = true
    @constructor.CELLS[@game].splice(@constructor.CELLS[@game].indexOf(@),1)
    delay 500, =>
      @el.remove()


  fallTo: (rowId) ->
    
    @setRow(rowId)
    @setBottom(@constructor.WRAPPER_HEIGHT - (@constructor.CELL_SIZE * rowId))
    
  ###
    The heart of the action:
    When you click on something
     - toggle it's active state
     - check how many are active
        - if a switch is in order, do it
          - if the switch is valid, collapse the cells
          - if cells are collapsed, add new cells
            - repeat 'recurssively' until there are no cells cleared
  ###
  click: () ->

    if (@isActive())
      @setActive(false)
    else
      @setActive(true)

      selected = @constructor.getActive(@game)
      if selected.length == 2
        success = @constructor.switchSquares(selected[0],selected[1])
        if success
          delay 1000, =>
             @constructor.updateBoard(@game)
        else
          selected[0].setActive(false)

      else if selected.length > 2
        console.log("Too many active: ", selected )
    
###
  Switch two squares
###
Cell.switchSquares = (el1, el2) ->
  
    
    bottom1 = el1.getBottom()
    bottom2 = el2.getBottom()
    left1 = el1.getLeft()
    left2 = el2.getLeft()
    col1 = el1.getCol()
    col2 = el2.getCol()
    row1 = el1.getRow()
    row2 = el2.getRow()
    
    if @areNeighbors(el1,el2)
      el1.setBottom(bottom2)
      el1.setLeft(left2)
      el1.setCol(col2)
      el1.setRow(row2)
      
      el2.setBottom(bottom1)
      el2.setLeft(left1)
      el2.setCol(col1)
      el2.setRow(row1)
      
      @sortCells(el1.game)
      
      delay 200, => 
        @clearActive(el1.game)
                
      return true
    else
      return false



###
  Get a square's neighbors - if `requireSameType` is passed in, return only neighbors matching the type
###
Cell.getNeighbors = (cell,requireSameType) ->
  
  bottom = cell.getBottom()
  left = cell.getLeft()
  
  neighbors = []

  for key,value of @CELLS[cell.game]
    #and then this happened -
    # not as bad as it looks.
    # - same col? pick one within a row above or row below 
    # - same row? pick one within a col on either side
    # - only looking for neighbors of the same type, add that in at the end
    if ((value.getBottom() >= bottom-@CELL_SIZE && value.getBottom() <= bottom+@CELL_SIZE) && value.getLeft() == left ||
        (value.getLeft() >= left-@CELL_SIZE && value.getLeft() <= left+@CELL_SIZE) && value.getBottom() == bottom)
      if (!requireSameType || (requireSameType && cell.getType() == value.getType()))        
        neighbors.push value unless value == cell
  
  #if (neighbors.length > 1)
  #  for key,value of neighbors
  #    neighbors.concat @getNeighbors(value,true, neighbors)
  #  
  #console.log(cell.getId() + " has " + neighbors.length + " neighbors")
  neighbors


###
  Helper to check if two cells are neighbors, wraps Class.getNeighbors.
  TODO: look into caching neighbors and blowing the cache on Cells.sort
###
Cell.areNeighbors = (el1,el2) ->
  
  neighbors = @getNeighbors(el1)
  found = false
  
  for key,value of neighbors
    if value == el2
      found = true
  found


###
  The heart of the clearing logic 
    - loop through every cell
    - count it's neighbors
    - more than 2? Add to the list of cells that should be cleared.
    - when done, clear those cells and return the cells cleared so we can keep the process going until no cells were cleared
###
Cell.removeClusters = (cells) ->
  
  removed= []
  toRemove = []
  
  addOnce = (v) ->
    unless removed.indexOf(v.getId()) > -1
      removed.push(v.getId()) 
      toRemove.push(v)  
  
  for key,value of cells
    neighbors = @getNeighbors(value, true)
    if (neighbors.length >= 2)
      addOnce(value)
      for n in neighbors
          do =>
            addOnce(n)
  
  for n in toRemove
    n.explode()
    
  toRemove

###
  After a move, run through the board recursively repeating the collapse,addCells process until nothign's cleared
###
Cell.updateBoard = (game) ->
    rounds = 0
    numRemoved = true
    totalRemoved = 0
    
    doRemove = (cells) =>
      removed = @removeClusters(cells)
      
      numRemoved = removed.length
      totalRemoved += numRemoved
      rounds++
      
      $(window).trigger('cells_cleared',[game,numRemoved, rounds])
      

      if numRemoved > 0
        
        @collapseCells(game)
        
        delay 350, =>
          doRemove(@CELLS[game])
          
      else
        @sortCells(game)

        values = []
        for key,value of @CELLS[game]
          values.push(value.getType())

        $("#edit_game_"+game+" [name='game[cells]']").each ->
          $(this).val(values.join(','))

        $("#edit_game_"+game+".hidden-form-submission").submit()
    
    doRemove(@CELLS[game])
    
    true



###
  THESE ARE HELPERS THAT SHOULD BE MOVED TO GAME CLASS AS THEY REQUIRE A GAME ID
###


#Return all cells for a given game that are active - could easily be cached for performance 
#(i.e save a reference to an active square instead of marking a square as active)
Cell.getActive = (game)->
  active = []
  for key,value of Peekeweled.classes.Cell.CELLS[game]
      active.push(value) if value.isActive()
      
  active

#mark all as inactive - happens after the update board process
Cell.clearActive = (game)->
  for key,value of @getActive(game)
    value.setActive(false)
  
#sort the cells by col so we can add cells by col 
Cell.getByCol = (game) ->
  cols = {}

  for key,value of @CELLS[game]

    unless cols[value.getCol()]
      cols[value.getCol()] = []
    
    
    cols[value.getCol()].push(value) unless value.isExploded() == true
  
  cols

#extremely import method that keeps the cells in order of how they appear so looping works logically. 
#Called whenver a change occurs
Cell.sortCells = (game) ->
  @CELLS[game].sort (a,b) ->
    if (a.getRow() == b.getRow())
      return a.getCol() - b.getCol()
    else
      return a.getRow() - b.getRow()

    result

#After a clear, collapse the cells down
Cell.collapseCells = (game) ->
  
    cols = @getByCol(game)

    #at this point we have the cells grouped by columns
    for colNum,cells of cols
      numNeeded = 8 - cells.length
      count = 8
      for rowNum,cell of cells.reverse()
         cell.fallTo(count--)
      
      if numNeeded > 0
        @addCellsToCol(game, colNum, numNeeded)
        
#After a collapse, add more cells
Cell.addCellsToCol = (game, col,num) ->

  for i in [num..1] by -1

    pick = @BANK[game].shift()
    
    if pick
      newEl = new Cell($('<a data-num="'+(Date.now())+'" data-type="'+pick+'" class="square square-'+pick+' on-deck">'), false,game)

      newEl.el.prependTo('[data-game-id="'+game+'"]')
      newEl.setCol(col)
      newEl.setRow(i-5)
      newEl.el.removeClass('on-deck')
    
      do (newEl, i) ->
        delay 0, ->
          newEl.setRow(i)
    else
      alert("Whoops. We are out of pieces. This is the only major outstanding bug and relatively easy to fix") 
    
  
  @sortCells(game)

#Called when the server embeds the GameBoard. This is so that in a dual mode, both teams have the same exact conditions.
Cell.setCellBank = (game, cells) ->
  @BANK[game] = cells.split(',')

window.namespace "Peekeweled.classes", (exports) ->
  exports.Cell = Cell