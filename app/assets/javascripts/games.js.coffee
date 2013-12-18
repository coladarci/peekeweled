# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Pekewled = {}

getNeighbors = (cell) ->
  cellSize = cell.width()*1
  top = cell.attr('data-top')*1
  left = cell.attr('data-left')*1
  
  selectors = [ '[data-top="'+Math.round(top+cellSize)+'"][data-left="'+left+'"]',
                '[data-top="'+Math.round(top-cellSize)+'"][data-left="'+left+'"]',
                '[data-left="'+Math.round(left+cellSize)+'"][data-top="'+top+'"]',
                '[data-left="'+Math.round(left-cellSize)+'"][data-top="'+top+'"]']
  
  $(selectors.join(','))

areNeighbors = (el1,el2) ->
  
  neighbors = getNeighbors(el1)
  found = false
  
  $.each neighbors, ->
    if $(this).data('num') == el2.data('num')
      found = true
  
  found
  
delay = (ms, func) -> setTimeout func, ms

switchSquares = (elements) ->
  
  el1 = $(elements[0])
  el2 = $(elements[1])
  
  css1 = {left: el1.css('left'), top: el1.css('top')}
  css2 = {left: el2.css('left'), top: el2.css('top')}
  
  top1 = el1.attr('data-top')
  top2 = el2.attr('data-top')
  left1 = el1.attr('data-left')
  left2 = el2.attr('data-left')

  if areNeighbors(el1,el2)
    el1.css(css2)
    el2.css(css1)
    el1.attr("data-top",    top2)
    el1.attr("data-left",   left2)
    el2.attr("data-top",   top1)
    el2.attr("data-left",  left1)

    delay 200, -> elements.removeClass('active')
    return true
  else
    return false
  
  
updateBoard = () ->
  
  
  
$ ->
  Pekewled.squares = $("#game_wrapper .square")
  
  Pekewled.squares .each ->
    offset = $(this).position()
    $(this).css({
      top : offset.top,
      left: offset.left
    }).attr({
      "data-top": offset.top,
      "data-left": offset.left 
    })
  
  delay 50, -> Pekewled.squares.addClass("rendered")
  
  $("#game_wrapper .square").on 
      click:->
          $(this).addClass("active")
          
          selected = Pekewled.squares.filter('.active')
          
          if selected.length == 2
            success = switchSquares(selected)
            if success
              delay 1000, updateBoard
            else
              $(this).removeClass("active")
              
          false