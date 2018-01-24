# Tangram in Elm

Tangram application written in Elm and based on https://github.com/fredcy/elm-tangram-svg

$ elm-live src/elm/Main.elm --output=docs/main.js --debug --pushstate --dir=docs

http://localhost:8000/

## To deploy in surge

```
$ mv docs/index.html docs/200.html
$ surge docs
```

## Using browser history as Undo/Redo

If our app is simple enough and the states can be expressed with a reasonable length size string, it is possible to use the browser history as Undo/Redo feature.

Let's have a look at this example Tangram editor.

As we move pieces or interact in some other way, you can see the url changing accordingly. For example:

[http://elm-tangram.surge.sh/☞,0,333,Elm_▢,250,200,180_▱,175,125,180_△,200,250,0_▷,150,200,90_▽,200,175,180_◁,275,250,270_◹,275,125,45](http://elm-tangram.surge.sh/☞,0,333,Elm_▢,250,200,180_▱,175,125,180_△,200,250,0_▷,150,200,90_▽,200,175,180_◁,275,250,270_◹,275,125,45)

Pressing the familiar ⌘Z or is possible to move back and forward in our undo list.

Selecting "Undo" from the browser Edit menu will not have the same effect.

(check if there is an event in JS to intercept Undo/Redo)

First of all we need to implement the navigation of the app as Single Page Application using Navigation.

```
main : Program String Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
```

Then in our init file we need to take care of the initial address:

```
init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        path =
            location.pathname
                |> String.dropLeft 1
                |> Http.decodeUri
                |> Maybe.withDefault ""

        model =
            pathToModel
                if path == "" then
                     startingPath
                else
                    path
    in
    model ! []
```

`pathToModel` is the function that transform the path to a model.
