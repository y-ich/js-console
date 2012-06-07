html_escape = (str) -> str.replace /[&<>"']/g, (m) -> "&#"+m.charCodeAt(0)+';'

log = document.createElement 'div'
log.setAttribute 'style', 'width: 100%; height: 3em; background-color: black; color: white; overflow: auto; -webkit-overflow-scrolling: touch;'
original_log = console.log
console.log = (msg) ->
    log.innerHTML += html_escape(msg.toString()) + '<br />'
    log.scrollTop = log.scrollHeight
    original_log.call console, msg
    null

input = document.createElement 'input'
input.type = 'text'
input.size = '80'
input.addEventListener 'change', ->
    console.log '> ' + input.value
    try 
        console.log eval input.value
    catch e
        console.log e.message

container = document.createElement 'div'
container.setAttribute 'style', 'width: 100%; border: solid, 1px, red; position: absolute; top: 0;'
container.appendChild log
container.appendChild input

window.addEventListener 'load', ->
    document.body.appendChild container
