module Tangram.Model
    exposing
        ( Model
        , colorCombinationToString
        , confStringToConf
        , confToConfString
        , init
        , modelToPath
        , modelToPathSorted
        , modelToStructure
        , pathToConf
        , pathToPieces
        , pathToStructure
        , startingPath
        , structureToPath
        , subscriptions
        )

import Color
import Colors
import Keyboard
import Mouse
import Piece.Model
import Piece.Types
import Tangram.Types
import Task
import Window


type alias Model =
    { pieces : List ( Tangram.Types.Name, Piece.Model.Model )
    , windowSize : Window.Size
    , keyShiftDown : Bool
    , keyCommandDown : Bool
    , keyControlDown : Bool
    , strokeOffset : Float
    , strokeColor : Colors.Color
    , canvasColor : Colors.Color
    , colorCombination : Tangram.Types.ColorCombination
    , name : String
    , errors : List String
    , rectDrag : Maybe Tangram.Types.Drag
    , pieceDragging : Bool
    , counter : Int
    , pointer : Mouse.Position
    }


pathToConf : Tangram.Types.Path -> Tangram.Types.Conf
pathToConf path =
    path
        |> pathToConfOfString
        |> confStringToConf


init : Tangram.Types.Path -> ( Model, Cmd Tangram.Types.Msg )
init path =
    let
        conf =
            pathToConf path
    in
    ( { pieces = pathToPieces path
      , colorCombination = conf.colorCombination
      , strokeOffset = conf.strokeOffset
      , strokeColor = conf.strokeColor
      , canvasColor = conf.canvasColor
      , windowSize = Window.Size 600 600
      , keyShiftDown = False
      , keyCommandDown = False
      , keyControlDown = False
      , name = "Default"
      , errors = []
      , rectDrag = Nothing
      , pieceDragging = False
      , counter = 0
      , pointer = Mouse.Position 0 0
      }
    , Cmd.batch
        [ Task.perform Tangram.Types.WindowSize Window.size

        --, Task.attempt GetLayout (LocalStorage.get (storageName defaultName))
        ]
    )


pathToConfOfString : Tangram.Types.Path -> Tangram.Types.ConfString
pathToConfOfString path =
    let
        structure =
            pathToStructure path
    in
    { id = structure.conf.id
    , strokeOffset = structure.conf.strokeOffset
    , strokeColor = structure.conf.strokeColor
    , canvasColor = structure.conf.canvasColor
    , colorCombination = structure.conf.colorCombination
    }


pathToPieces : Tangram.Types.Path -> List ( Piece.Types.Id, Piece.Model.Model )
pathToPieces path =
    let
        structure =
            pathToStructure path
    in
    List.map
        (\piece ->
            pieceGenerator structure.conf piece
        )
        structure.pieces


pathToStructure : Tangram.Types.Path -> Tangram.Types.Structure
pathToStructure path =
    let
        headList list =
            Maybe.withDefault [] (List.head list)

        head list =
            Maybe.withDefault "" (List.head list)

        tail list =
            Maybe.withDefault [] (List.tail list)

        allSplit =
            List.map
                (\piece ->
                    String.split separators.betweenData piece
                )
                (String.split separators.betweenPieces path)

        confList =
            headList allSplit

        piecesListList =
            tail allSplit

        conf =
            { id = head confList
            , strokeOffset = head <| tail confList
            , strokeColor = head <| tail <| tail confList
            , canvasColor = head <| tail <| tail <| tail confList
            , colorCombination = head <| tail <| tail <| tail <| tail confList
            }

        pieces =
            List.map
                (\piece ->
                    { id = head piece
                    , x = head <| tail piece
                    , y = head <| tail <| tail piece
                    , deg = head <| tail <| tail <| tail piece
                    }
                )
                piecesListList
    in
    { conf = conf, pieces = pieces }


structureToPath : Tangram.Types.Structure -> Tangram.Types.Path
structureToPath structure =
    let
        conf =
            String.join separators.betweenData
                [ structure.conf.id
                , structure.conf.strokeOffset
                , structure.conf.strokeColor
                , structure.conf.canvasColor
                , structure.conf.colorCombination
                ]

        pieces =
            String.join separators.betweenPieces
                (List.map
                    (\piece ->
                        String.join separators.betweenData
                            [ piece.id
                            , piece.x
                            , piece.y
                            , piece.deg
                            ]
                    )
                    structure.pieces
                )
    in
    conf ++ separators.betweenPieces ++ pieces


startingCanvasColor : Colors.Color
startingCanvasColor =
    Colors.darkGray


startingPath : String
startingPath =
    "/☞,3,"
        ++ Colors.colorToNakedString startingCanvasColor
        ++ ","
        ++ Colors.colorToNakedString startingCanvasColor
        ++ ",Elm_▢,250,200,180_▱,175,125,180_△,200,250,0_▷,150,200,90_▽,200,175,180_◁,275,250,270_◹,275,125,45"


separators : { betweenData : String, betweenPieces : String }
separators =
    { betweenData = ","
    , betweenPieces = "_"
    }


modelToConf : Model -> List String
modelToConf model =
    [ "☞"
    , toString model.strokeOffset
    , Colors.colorToNakedString model.strokeColor
    , Colors.colorToNakedString model.canvasColor
    , colorCombinationToString model.colorCombination
    ]


modelToPath : Model -> Tangram.Types.Path
modelToPath model =
    model.pieces
        |> List.map (\( pieceId, { position, rotation } ) -> encodePiece pieceId position rotation)
        |> (::) (String.join separators.betweenData (modelToConf model))
        |> String.join separators.betweenPieces


modelToPathSorted : Model -> List ( String, Piece.Model.Model ) -> String
modelToPathSorted model pieces =
    pieces
        |> List.map (\( pieceId, { position, rotation } ) -> encodePiece pieceId position rotation)
        |> List.sort
        |> (::) (String.join separators.betweenData (modelToConf model))
        |> String.join separators.betweenPieces


encodePiece : String -> Piece.Types.Position -> Float -> String
encodePiece pieceId position rotation =
    pieceId
        ++ separators.betweenData
        ++ String.join separators.betweenData
            [ toString position.x
            , toString position.y
            , toString <| round <| radToDeg rotation
            ]


colorCombinationToString : Tangram.Types.ColorCombination -> String
colorCombinationToString v =
    case v of
        Tangram.Types.Color color ->
            Colors.colorToNakedString color

        Tangram.Types.Rainbow ->
            "🌈"

        Tangram.Types.Elm ->
            "🌳"



--_ ->
--    toString v


stringToColorCombination : String -> Tangram.Types.ColorCombination
stringToColorCombination v =
    case v of
        "🌈" ->
            Tangram.Types.Rainbow

        "🌳" ->
            Tangram.Types.Elm

        _ ->
            Tangram.Types.Color <| Colors.stringToColor <| "#" ++ v


confStringToConf : Tangram.Types.ConfString -> Tangram.Types.Conf
confStringToConf conf =
    let
        toInt a =
            Result.withDefault 0 (String.toInt a)
    in
    { id = conf.id
    , strokeOffset = toFloat <| toInt conf.strokeOffset
    , strokeColor = Colors.stringToColor ("#" ++ conf.strokeColor)
    , canvasColor = Colors.stringToColor ("#" ++ conf.canvasColor)
    , colorCombination = stringToColorCombination conf.colorCombination
    }


confToConfString : Tangram.Types.Conf -> Tangram.Types.ConfString
confToConfString confString =
    { id = confString.id
    , strokeOffset = toString <| floor confString.strokeOffset
    , strokeColor = Colors.colorToNakedString confString.strokeColor
    , canvasColor = Colors.colorToNakedString confString.canvasColor
    , colorCombination = colorCombinationToString confString.colorCombination
    }


fromPieceOfStringsToPiece : Tangram.Types.PieceString -> Tangram.Types.Piece
fromPieceOfStringsToPiece piece =
    let
        toInt a =
            Result.withDefault 0 (String.toInt a)
    in
    { id = piece.id
    , x = toInt piece.x
    , y = toInt piece.y
    , deg = degToRad <| toFloat <| toInt piece.deg
    }


pieceGenerator :
    Tangram.Types.ConfString
    -> Tangram.Types.PieceString
    -> ( Piece.Types.Id, Piece.Model.Model )
pieceGenerator confString pieceString =
    let
        conf =
            confStringToConf confString

        piece =
            fromPieceOfStringsToPiece pieceString

        color =
            pieceColor piece.id conf.colorCombination

        shape =
            pieceShape piece.id color

        position =
            Piece.Types.Position piece.x piece.y
    in
    ( piece.id, Piece.Model.init shape position piece.deg conf.strokeOffset conf.strokeColor )


pieceShape : String -> Colors.Color -> Piece.Types.Shape
pieceShape id color =
    case id of
        "△" ->
            Piece.Types.Triangle color 100.0

        "▷" ->
            Piece.Types.Triangle color 100.0

        "◹" ->
            Piece.Types.Triangle color (100.0 / sqrt 2)

        "◁" ->
            Piece.Types.Triangle color (100.0 / 2)

        "▽" ->
            Piece.Types.Triangle color (100.0 / 2)

        "▢" ->
            Piece.Types.Square color 100.0

        "▱" ->
            Piece.Types.Parallelogram color 100.0

        "▰" ->
            Piece.Types.ParallelogramInverted color 100.0

        _ ->
            Piece.Types.Square Colors.black 50.0


pieceColor : Piece.Types.Id -> Tangram.Types.ColorCombination -> Colors.Color
pieceColor pieceId combination =
    colorCombinations combination
        |> List.filter (\( id, color ) -> pieceId == id)
        |> List.head
        |> Maybe.withDefault ( "", Colors.gray )
        |> Tuple.second


colorCombinations : Tangram.Types.ColorCombination -> List ( Piece.Types.Id, Colors.Color )
colorCombinations combination =
    case combination of
        Tangram.Types.Elm ->
            [ ( "△", Colors.elmTurquoise )
            , ( "▷", Colors.elmGray )
            , ( "◹", Colors.elmTurquoise )
            , ( "◁", Colors.elmOrange )
            , ( "▽", Colors.elmOrange )
            , ( "▢", Colors.elmGreen )
            , ( "▱", Colors.elmGreen )
            , ( "▰", Colors.elmGreen )
            ]

        Tangram.Types.Rainbow ->
            [ ( "△", Color.lightRed )
            , ( "▷", Color.lightOrange )
            , ( "◹", Color.lightBlue )
            , ( "◁", Color.lightGreen )
            , ( "▽", Color.white )
            , ( "▢", Color.lightPurple )
            , ( "▱", Color.lightYellow )
            , ( "▰", Color.lightYellow )
            ]

        Tangram.Types.Color color ->
            [ ( "△", color )
            , ( "▷", color )
            , ( "◹", color )
            , ( "◁", color )
            , ( "▽", color )
            , ( "▢", color )
            , ( "▱", color )
            , ( "▰", color )
            ]


{-| Gather the subscriptions of each of the components into a single Batch.
-}
subscriptions : Model -> Sub Tangram.Types.Msg
subscriptions model =
    let
        mapSubs ( name, piece ) =
            Piece.Model.subscriptions piece |> Sub.map (Tangram.Types.PieceMsg name)

        reSize =
            Window.resizes Tangram.Types.WindowSize

        keyDowns =
            Keyboard.downs Tangram.Types.KeyDown

        keyUps =
            Keyboard.ups Tangram.Types.KeyUp

        mouse =
            case model.rectDrag of
                Nothing ->
                    []

                Just _ ->
                    if model.pieceDragging then
                        []
                    else
                        [ Mouse.moves Tangram.Types.RectDragAt, Mouse.ups Tangram.Types.RectDragEnd ]
    in
    -- [ keyUps, keyDowns, reSize, mouseMoves, mouseUps ] ++ List.map mapSubs model.pieces |> Sub.batch
    [ keyUps, keyDowns, reSize ] ++ mouse ++ List.map mapSubs model.pieces |> Sub.batch


modelToStructure : Model -> Tangram.Types.Structure
modelToStructure model =
    model
        |> modelToPath
        |> pathToStructure


radToDeg : Float -> Float
radToDeg rad =
    -- Radiants to Degrees
    let
        deg =
            (rad * 180) / pi

        normalizedDeg =
            if deg >= 360 then
                deg - 360
            else if deg < 0 then
                deg + 360
            else
                deg
    in
    normalizedDeg


degToRad : Float -> Float
degToRad deg =
    -- Degrees to Radiants
    (deg / 180) * pi
