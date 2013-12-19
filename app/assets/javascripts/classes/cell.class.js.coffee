delay = window.Peekeweled.helpers.delay
  
class Cell
  
  #we store all cells here so we are hitting the dom as little as possible
  @CELLS = {}
  @BANK = {}
  
  constructor: ($el, $wrapperHeight, gameId) ->
    @el = $el 
    @game = gameId
    
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

    @el.data('obj', @)
        
    @el.on 
        click: (e) =>
            @click()
            false
    
    if !@constructor.CELLS[gameId] 
      @constructor.CELLS[gameId] = []

    @constructor.CELLS[gameId].push(@)
    

  
  
    
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
    
Cell.getActive = (game)->
  active = []
  for key,value of Peekeweled.classes.Cell.CELLS[game]
      active.push(value) if value.isActive()
      
  active

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
  
Cell.clearActive = (game)->
  for key,value of @getActive(game)
    value.setActive(false)
  
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

Cell.areNeighbors = (el1,el2) ->
  
  neighbors = @getNeighbors(el1)
  found = false
  
  for key,value of neighbors
    if value == el2
      found = true
  found

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

Cell.getByCol = (game) ->
  cols = {}

  for key,value of @CELLS[game]

    unless cols[value.getCol()]
      cols[value.getCol()] = []
    
    
    cols[value.getCol()].push(value) unless value.isExploded() == true
  
  cols
  
Cell.sortCells = (game) ->
  @CELLS[game].sort (a,b) ->
    if (a.getRow() == b.getRow())
      return a.getCol() - b.getCol()
    else
      return a.getRow() - b.getRow()

    result
    
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

Cell.addCellsToCol = (game, col,num) ->

  for i in [num..1] by -1

    pick = @BANK[game].shift()

    newEl = new Cell($('<a data-num="'+(Date.now())+'" data-type="'+pick+'" class="square square-'+pick+' on-deck">'), false,game)

    newEl.el.prependTo('[data-game-id="'+game+'"]')
    newEl.setCol(col)
    newEl.setRow(i-5)
    newEl.el.removeClass('on-deck')
    
    do (newEl, i) ->
      delay 0, ->
        newEl.setRow(i)
    
  
  @sortCells(game)

Cell.setCellBank = (game, cells) ->
  @BANK[game] = cells.split(',')

window.namespace "Peekeweled.classes", (exports) ->
  exports.Cell = Cell