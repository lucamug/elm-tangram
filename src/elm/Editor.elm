module Editor exposing (Model, Msg(TangramMsg), init, subscriptions, update, view)

import Html exposing (Html)
import Mouse
import Tangram.Model
import Tangram.Types
import Tangram.Update
import Tangram.View


type alias Model =
    { tangram : Tangram.Model.Model
    , pointer : Mouse.Position
    }


type Msg
    = TangramMsg Tangram.Types.Msg
    | MousePos ( Mouse.Position, Mouse.Position )


init : Tangram.Model.Model -> ( Model, Cmd Msg )
init tangram =
    { tangram = tangram
    , pointer = Mouse.Position 0 0
    }
        ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TangramMsg tmsg ->
            let
                ( tmodel, tcmd ) =
                    Tangram.Update.update tmsg model.tangram
            in
            { model | tangram = tmodel } ! [ Cmd.map TangramMsg tcmd ]

        MousePos ( pagePos, offsetPos ) ->
            { model | pointer = offsetPos } ! []


view : Model -> Html Msg
view model =
    Tangram.View.view model.tangram |> Html.map TangramMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Tangram.Model.subscriptions model.tangram |> Sub.map TangramMsg
