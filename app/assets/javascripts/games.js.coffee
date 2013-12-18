# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  
$ ->
  window.peekeweled_instance = new window.Peekeweled.classes.Game($("#game_wrapper"))