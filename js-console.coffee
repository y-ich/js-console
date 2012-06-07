original_log = console.log
console.log = (msg) ->
    div = document.getElementById 'js-console'
    div.innerHTML += msg + '<br />'
    div.scrollTop = div.scrollHeight
    original_log.call console, msg
    null

window.addEventListener 'load', ->
    div = document.createElement 'div'
    div.id = 'js-console'
    div.setAttribute 'style', 'width: 100%; height: 3em; border: solid, 1px, red; background-color: black; color: white; position: fixed; bottom: 0; overflow: auto; -webkit-overflow-scrolling: touch;'
    document.body.appendChild div
