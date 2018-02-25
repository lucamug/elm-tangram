# Tangram in Elm

[Demo](http://elm-tangram.surge.sh/)

[Post](https://medium.com/@l.mugnaini/undo-and-redo-using-browsers-history-1f1f963bf722)

![Screencast](http://elm-tangram.surge.sh/images/elm-tangram-animation.gif)

Tangram application written in Elm based on https://github.com/fredcy/elm-tangram-svg

$ elm-live src/elm/Main.elm --output=docs/main.js --debug --pushstate --dir=docs

http://localhost:8000/

## To deploy in surge

```
$ mv docs/index.html docs/200.html
$ surge docs
```

## Using browser history as Undo/Redo

If we have a simple enough application where the state of the application (model) can be converted to a string, we can leverage the browser built-in history functionality to implement a Undo-Redo feature.

To build this in Elm we need

* A function that convert the model to string and vice-versa
* A SPA implemented with pushstate
* A function that detect the press of ⌘Z (Undo) and ⇧⌘Z (Redo)

This is a demo of this implementation. After opening the app, try moving the tangram pieces or selecting other configuration from the buttons at the top. You can see the url in the address bar changing accordingly.

Now pressing ⌘Z or ⇧⌘Z we will be able to move back and forward in the state history.

Have a look at the code for details of the implementation.
