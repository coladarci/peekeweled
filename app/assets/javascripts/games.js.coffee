# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  
$ ->
  $('.game_board').each ->
    new window.Peekeweled.classes.Game($(this))