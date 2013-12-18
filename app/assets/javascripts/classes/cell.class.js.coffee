delay = window.Peekeweled.helpers.delay
  
class Cell
  @CELLS = []
  
  constructor: ($el) ->
    @el = $el 
    
    if (!@constructor.CELL_SIZE )
      @constructor.CELL_SIZE = @el.width()
    
    #run through floated grid and "lock in" position absolutely
    #this coculd be done other ways but this allows the potential for using floats to our advantage for fluidness
    offset = $el.position()
    $el.css({
      top : offset.top,
      left: offset.left
    }).attr({
      "data-top": offset.top,
      "data-left": offset.left 
    })
    
    @el.on 
        click: (e) =>
            @click()
            false
    
    @constructor.CELLS.push(@)
  
  
    
  getTop: () ->
    @el.attr('data-top')*1
  getLeft: () ->
    @el.attr('data-left')*1
  setTop: (v) ->
    @el.attr('data-top',v)
    @el.css('top', v + "px")
  setLeft: (v) ->
    @el.attr('data-left',v)
    @el.css('left', v + "px")

  isActive: ->
    return @active == true
  setActive: (v) ->
    @active = v
    if v
      @el.addClass('active')
    else
      @el.removeClass('active')
      
  click: () ->
    
    if (@isActive())
      @setActive(false)
    else
      @setActive(true)

      selected = @constructor.getActive()

      if selected.length == 2
        success = @constructor.switchSquares(selected[0],selected[1])
        if success
          delay 1000, @constructor.updateBoard
        else
          @setActive(false)
      else if selected.length > 2
        console.log("Too many active: ", selected )
    
Cell.getActive = ->
  active = []
  for key,value of Peekeweled.classes.Cell.CELLS
      active.push(value) if value.isActive()
      
  active

Cell.switchSquares = (el1, el2) ->
  
    top1 = el1.getTop()
    top2 = el2.getTop()
    left1 = el1.getLeft()
    left2 = el2.getLeft()
    
    if @areNeighbors(el1,el2)
      el1.setTop(top2)
      el1.setLeft(left2)
      el2.setTop(top1)
      el2.setLeft(left1)

      delay 200, => 
        @clearActive()
                
      return true
    else
      return false
  
Cell.clearActive = ->
  for key,value of @getActive()
    value.setActive(false)
  
Cell.getNeighbors = (cell) ->
  top = cell.getTop()
  left = cell.getLeft()
  
  neighbors = []

  for key,value of @CELLS
    if ((value.getTop() >= top-@CELL_SIZE && value.getTop() <= top+@CELL_SIZE) && value.getLeft() == left ||
        (value.getLeft() >= left-@CELL_SIZE && value.getLeft() <= left+@CELL_SIZE) && value.getTop() == top)
      neighbors.push value

  neighbors

Cell.areNeighbors = (el1,el2) ->
  
  neighbors = @getNeighbors(el1)
  found = false
  
  for key,value of neighbors
    if value == el2
      found = true
  found

Cell.updateBoard = ->
    
    
 
  
window.namespace "Peekeweled.classes", (exports) ->
  exports.Cell = Cell