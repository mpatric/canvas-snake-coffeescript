find = (array, test) ->
  for i in [0...array.length]
    return array[i] if test(array[i])

arrayHas = (array, test) ->
  find(array, test) != undefined

randomNumber = (options) ->
  Math.floor(Math.random() * options)

randomColour = () ->
  "##{(randomNumber(16)).toString(16)}#{(randomNumber(16)).toString(16)}#{(randomNumber(16)).toString(16)}"

registerEventHandler = (node, event, handler) ->
  if typeof node.addEventListener == "function"
    node.addEventListener(event, handler, false)
  else
    node.attachEvent("on" + event, handler)
