delay = (ms, func) -> setTimeout func, ms

#name spacing at end of classes
  
window.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top
     
namespace "Peekeweled.helpers", (exports) ->
  exports.delay = delay