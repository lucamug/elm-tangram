module Main exposing (main)

import Editor
import Html exposing (Html)
import Http
import Navigation
import Tangram.Model
import Tangram.Types
import Tangram.Update


--import Tangram.View as Tangram
{- I have both Editor and Tangram as components here to test that we can have
   both a simple (eventually) static view of a tangram and an interactive editor of
   tangrams.
-}


main : Program String Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { tangram : Tangram.Model.Model
    , editor : Editor.Model
    }


type Msg
    = TangramMsg Tangram.Types.Msg
    | EditorMsg Editor.Msg
    | UrlChange Navigation.Location


cleanPath : String -> String
cleanPath path =
    Maybe.withDefault "" <| Http.decodeUri <| String.dropLeft 1 path


init : String -> Navigation.Location -> ( Model, Cmd Msg )
init val location =
    let
        tempPath =
            cleanPath location.pathname

        path =
            if tempPath == "" then
                Tangram.Model.startingPath
            else
                tempPath

        ( tmodel, tcmd ) =
            Tangram.Model.init path

        ( etangram, ecmd ) =
            Tangram.Model.init path

        ( editorModel, editorCmd ) =
            Editor.init etangram
    in
    { tangram = tmodel
    , editor = editorModel
    }
        ! [ Cmd.map TangramMsg tcmd
          , Cmd.map (EditorMsg << Editor.TangramMsg) ecmd
          , Cmd.map EditorMsg editorCmd
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TangramMsg tmsg ->
            let
                ( tmodel, tcmd ) =
                    Tangram.Update.update tmsg model.tangram
            in
            { model | tangram = tmodel } ! [ Cmd.map TangramMsg tcmd ]

        EditorMsg emsg ->
            let
                ( emodel, ecmd ) =
                    Editor.update emsg model.editor
            in
            { model | editor = emodel } ! [ Cmd.map EditorMsg ecmd ]

        UrlChange location ->
            let
                newPath =
                    cleanPath location.pathname

                newConf =
                    Tangram.Model.pathToConf newPath

                newPieces =
                    Tangram.Model.pathToPieces newPath

                editor =
                    model.editor

                tangramModel =
                    editor.tangram

                newTangramModel =
                    { tangramModel
                        | pieces = newPieces
                        , strokeOffset = newConf.strokeOffset
                        , strokeColor = newConf.strokeColor
                        , canvasColor = newConf.canvasColor
                        , colorCombination = newConf.colorCombination
                    }

                newEditor =
                    { editor | tangram = newTangramModel }
            in
            { model | editor = newEditor } ! []


view : Model -> Html Msg
view model =
    Editor.view model.editor |> Html.map EditorMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- Tangram.Model.subscriptions model.tangram |> Sub.map TangramMsg
          Editor.subscriptions model.editor |> Sub.map EditorMsg
        ]
