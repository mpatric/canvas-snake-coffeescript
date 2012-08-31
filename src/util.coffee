randomNumber = (options) ->
  Math.floor(Math.random() * options)

randomColour = () ->
  "##{(randomNumber(16)).toString(16)}#{(randomNumber(16)).toString(16)}#{(randomNumber(16)).toString(16)}"

registerEventHandler = (node, event, handler) ->
  if typeof node.addEventListener == "function"
    node.addEventListener(event, handler, false)
  else
    node.attachEvent("on" + event, handler)

supports_local_storage = () ->
  try
    return 'localStorage' in window && window['localStorage'] != null
  catch e
    return false
