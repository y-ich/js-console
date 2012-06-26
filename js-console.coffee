# js-console: browser independent JavaScript console
# Copyright (C) 2012 ICHIKAWA, Yuji (New 3 Rs)
# Usage
# <script src="js-console-bundle.js"></script>
#
# complete button : complete a word before caret. continuous click shows next candicate.
# cursor right button : adopt completion
# log pane : toggle the postion when touching

parseJs = require './parse-js'

# functions

html_escape = (str) -> str.replace /[&<>"']/g, (m) -> "&#"+m.charCodeAt(0)+';'

original_log = console.log
console.log = (msg) ->
    log.innerHTML += html_escape(msg.toString()) + '<br />'
    log.scrollTop = log.scrollHeight
    original_log.call console, msg
    null

tokensIn = (str) ->
    next_token = parseJs.tokenizer str
    tokens = []
    try
        until (token = next_token()).type is 'eof'
            tokens.push token
    catch e # example unclosed string literal
        console.log "tokenizer error"
    tokens

# returns 'scratch' if no current object.
currentObject = (tokens) ->
    chain = []
    chain.push tokens[tokens.length - 1]
    i = tokens.length - 2
    while i >= 0
        if tokens[i].value isnt '.' # not property
            break
        i -= 1
        if tokens[i].type is 'name'
            if tokens[i].value is 'this' # treat this as {} since it is difficult to analyze what this is.
                chain.push {}
            else
                chain.push eval(tokens[i].value)
            i -= 1
        else
            if tokens[i].type is 'num'
                chain.push 0
            else if tokens[i].type is 'string'
                chain.push ''
            else if tokens[i].type is 'keyword'
                console.log 'parse error: named as keyword'
            else if tokens[i].value is ']'
                chain.push []
            else if tokens[i].value is '}'
                chain.push {}
            else if tokens[i].value is '/' # slash before dot should be a regular expression.
                chain.push new RegExp()
            break

    if chain.length == 1
        obj = 'scratch'
    else
        if typeof chain[chain.length - 1] is 'string'
            obj = if chain[chain.length - 1].length isnt 0
                    console.log chain[chain.length - 1]
                    window[chain[chain.length - 1]]
                else
                    ''
        else
            obj = chain[chain.length - 1]
        if chain.length - 2 >= 1
            for i in [chain.length - 2, 1]
                obj = obj[chain[i]]
    obj

lastCandidate =
    target : ''
    index : 0
    candicates : null

pickupCandidates = (obj, str) ->
    arrayProps = ["length", "pop", "push", "reverse", "shift", "sort", "splice", "unshift",
                  "concat", "join", "slice", "indexOf", "lastIndexOf",
                  "filter", "forEach", "every", "map", "some", "reduce", "reduceRight"]
    dateProps = ["getDate", "getDay", "getFullYear", "getHours", "getMilliseconds", "getMinutes", "getMonth", "getSeconds", "getTime", "getTimezoneOffset",
                 "getUTCDate", "getUTCDay", "getUTCFullYear", "getUTCHours", "getUTCMilliseconds", "getUTCMinutes", "getUTCMonth", "getUTCSeconds",
                 "setDate", "setFullYear", "setHours", "setMilliseconds", "setMinutes", "setMonth", "setSeconds", "setTime",
                 "setUTCDate", "setUTCFullYear", "setUTCHours", "setUTCMilliseconds", "setUTCMinutes", "setUTCMonth", "setUTCSeconds",
                 "toDateString", "toISOString", "toLocaleDateString", "toLocaleTimeString", "toTimeString", "toUTCString"]
    numberProps = ["toExponential", "toFixed", "toPrecision"]
    objectProps = ["constructor", "hasOwnProperty", "isPrototypeOf", "propertyIsEnumerable", "toLocaleString", "toString", "valueOf"]
    regexpProps = ["global", "ignoreCase", "lastIndex", "multiline", "source", "exec", "test"]
    stringProps = ["length", "charAt", "charCodeAt", "concat", "indexOf", "lastIndexOf", "localeCompare", "match", "replace", "search", "slice", "split", "substr", "substring", "toLocaleLowerCase", "toLocaleUpperCase", "toLowerCase", "toUpperCase"]
    funcProps = ["length", "apply", "call"]
    javascriptKeywords = ["break", "case", "catch", "continue", "default", "delete", "do", "else", "false", "finally", "for", "function", "if", "in", "instanceof", "new", "null", "return", "switch", "this", "throw", "true", "try", "typeof", "var", "void", "while", "with"]

    result = []

    if obj is 'scratch'
        result.push e for e in javascriptKeywords when e.indexOf(str) is 0
        result.push e for e of window when e.indexOf(str) is 0
    else
        switch typeof obj
            when 'number'
                result.push e for e in numberProps when e.indexOf(str) is 0
            when 'string'
                result.push e for e in stringProps when e.indexOf(str) is 0
            when 'function'
                result.push e for e in funcProps when e.indexOf(str) is 0
            when 'object', 'boolean'
                result.push e for e in objectProps when e.indexOf(str) is 0
                if obj instanceof Array
                    result.push e for e in arrayProps when e.indexOf(str) is 0
                else if obj instanceof Date
                    result.push e for e in dateProps when e.indexOf(str) is 0
                else if obj instanceof RegExp
                    result.push e for e in regexpProps when e.indexOf(str) is 0
                result.push e for e of obj when e.indexOf(str) is 0

    lastCandidate.target = str
    lastCandidate.index = 0
    lastCandidate.candidates = result.sort()

getCandidates = (str) ->
    tokens = tokensIn str + '$caret$' # $caret$ is dummy postfix of name to make sure for some token to exist at the position of caret. 
    return [] if tokens.length is 0 # for example, tokensIn with arugment of comment line returns empty array. 

    target = tokens[tokens.length - 1].value.replace('$caret$', '') # target for completing
    [target, pickupCandidates(currentObject(tokens), target)]


# HTML elements

log = document.createElement 'div'
log.setAttribute 'style', 'width: 100%; height: 3em; background-color: black; color: white; overflow: auto; -webkit-overflow-scrolling: touch;'
log.addEventListener 'click', ->
    if /0/.test(container.style.top)
        container.style.bottom = '0'
        container.style.top = ''
    else
        container.style.bottom = ''
        container.style.top = '0'

window.complete = document.createElement 'input'
complete.type = 'button'
complete.value = 'complete'
complete.addEventListener 'mousedown', (event) ->
    event.preventDefault() # prevent blurr of input field

complete.addEventListener 'click', ->
    beforeCursor = input.value.slice 0, input.selectionStart
    if input.selectionStart == input.selectionEnd # consider no selection as after completion
        [target, cand] = getCandidates beforeCursor
        if cand.length > 0
            start = input.selectionStart # selectionStart will be changed when value is changed.
            input.value = beforeCursor.replace(new RegExp(target + '$'), cand[0]) + input.value.slice(input.selectionStart)
            input.selectionStart = start
            input.selectionEnd = start + cand[0].length
    else
        lastCandidate.index += 1
        lastCandidate.index = 0 if lastCandidate.index >= lastCandidate.candidates.length
        start = input.selectionStart # selectionStart will be changed when value is changed.
        input.value = beforeCursor.replace(new RegExp(lastCandidate.target + '$'), lastCandidate.candidates[lastCandidate.index]) + input.value.slice(input.selectionEnd)
        input.selectionStart = start
        input.selectionEnd = start + lastCandidate.candidates[lastCandidate.index].length

window.input = document.createElement 'input'
input.type = 'text'
input.style.width = '90%'
input.addEventListener 'keydown', (event) ->
    if event.keyCode == 13 # return key
        console.log '> ' + input.value
        try 
            console.log(eval.call window, input.value)
        catch e
            console.log e.message

cursorLeft = document.createElement 'input'
cursorLeft.type = 'button'
cursorLeft.value = '◀'
cursorLeft.addEventListener 'mousedown', (event) ->
    event.preventDefault() # prevent blurr of input field
cursorLeft.addEventListener 'click', ->
    if input.selectionStart > 0
        input.selectionStart = input.selectionStart - 1 
        input.selectionEnd = input.selectionStart

cursorRight = document.createElement 'input'
cursorRight.type = 'button'
cursorRight.value = '▶'
cursorRight.addEventListener 'mousedown', (event) ->
    event.preventDefault() # prevent blurr of input field
cursorRight.addEventListener 'click', (event) ->
    if input.selectionStart == input.selectionEnd
        if input.selectionStart < input.value.length
            input.selectionStart = input.selectionStart + 1 
            input.selectionEnd = input.selectionStart
    else
        input.selectionStart = input.selectionEnd

# cursorUp = document.createElement 'input'
# cursorUp.type = 'button'
# cursorUp.value = '▲'
# cursorUp.addEventListener 'mousedown', (event) ->
#     event.preventDefault() # prevent blurr of input field
# cursorUp.addEventListener 'click', ->

# cursorDown = document.createElement 'input'
# cursorDown.type = 'button'
# cursorDown.value = '▼'
# cursorDown.addEventListener 'mousedown', (event) ->
#     event.preventDefault() # prevent blurr of input field
# cursorDown.addEventListener 'click', ->

container = document.createElement 'div'
container.setAttribute 'style', 'width: 100%; border: solid, 1px, red; position: fixed; bottom: 0;'
container.appendChild log
container.appendChild complete
container.appendChild input
container.appendChild cursorLeft
container.appendChild cursorRight
# container.appendChild cursorUp
# container.appendChild cursorDown


window.addEventListener 'load', ->
    document.body.appendChild container
    input.style.width = (innerWidth - complete.clientWidth - cursorLeft.clientWidth - cursorRight.clientWidth - 2 * 8 - 8 * 2 - 10) + 'px' # 2px margins for each edge of each elelement, 8px margins of body, 10px for itself.

