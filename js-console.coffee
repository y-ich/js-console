# js-console: browser independent JavaScript console
# Copyright (C) 2012 ICHIKAWA, Yuji (New 3 Rs)

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

candidates = (obj, str) ->
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

    result.sort()

getCandidates = (str) ->
    tokens = tokensIn str + '$caret$'
    return [] if tokens.length is 0 # for example, tokensIn with arugment of comment line returns empty array. 

    candidates currentObject(tokens), tokens[tokens.length - 1].value.replace('$caret$', '')


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


input = document.createElement 'input'
input.type = 'text'
input.size = '80'
input.addEventListener 'change', ->
    console.log '> ' + input.value
    try 
        console.log eval input.value
    catch e
        console.log e.message
input.addEventListener 'keyup', ->
    console.log getCandidates input.value.slice(0, input.selectionStart)


container = document.createElement 'div'
container.setAttribute 'style', 'width: 100%; border: solid, 1px, red; position: fixed; bottom: 0;'
container.appendChild log
container.appendChild input


window.addEventListener 'load', ->
    document.body.appendChild container
