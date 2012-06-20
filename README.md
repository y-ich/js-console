# js-console : JavaScript console by JavaScript

JavaScript development environments in desktop browsers are making rapid improvements these days. But how about mobile, or embeded browsers? 

This js-console provides JavaScript console for debugging by adding one line in your web page. 

* No framework libraries are needed.
* Auto completion

## Demo
http://y-ich.github.com/js-console/

## How to add the console to a web page
&lt;meta charset="UTF-8"&gt;

&lt;script src="js-console-bundle.js"&gt;&lt;/script&gt;

## Usage
### Basic
1. Input some JavaScript expression in the text field.
2. Type return key, then a result will appear black pane.
You can use cursor buttons at the right side of the text field for editing.

### Additional functions

#### Switching the position of the console
Click black pane, then the position will change up and down.

#### Auto completion
Click "complete" button, then letters right before the caret will be completed to a candicate.

Click "compelete" button successively, then next candicate will appear.

Click cursor-right button, then the candidate will be adopted.

## Acknowledge
js-console uses parse-js.js and is built by browserify. I appreciate both projects.

* parse-js.js in <a href="https://github.com/mishoo/UglifyJS">UglifyJS</a>
* <a href="https://github.com/substack/node-browserify">browerify</a>
