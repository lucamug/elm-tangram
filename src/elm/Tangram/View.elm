module Tangram.View exposing (view)

import Color
import Colors
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import Piece.Model
import Piece.View as Piece
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Svg.Lazy exposing (lazy, lazy3)
import Tangram.Model exposing (Model)
import Tangram.Types exposing (..)
import VirtualDom


onLinkClick : String -> Html.Attribute Msg
onLinkClick path =
    Html.Events.onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Decode.succeed (ChangeLocation path))


onLinkClickToggle : String -> Html.Attribute Msg
onLinkClickToggle path =
    Html.Events.onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Decode.succeed (ChangeLocationAndToggle path))


viewLink : String -> String -> Html Msg
viewLink url string =
    Html.button [ Html.Attributes.href url, onLinkClick url ] [ Html.text string ]


viewToggleLink : String -> String -> Html Msg
viewToggleLink url string =
    Html.button [ Html.Attributes.href url, onLinkClickToggle url ] [ Html.text string ]


margin : Int
margin =
    10


view : Model -> Html.Html Msg
view model =
    let
        baseColor =
            Colors.colorToNakedString Colors.elmOrange

        canvasColor =
            Colors.colorToNakedString model.canvasColor

        confString =
            model
                |> Tangram.Model.modelToStructure
                |> .conf

        neutralStart =
            "/☞,"
                ++ confString.strokeOffset
                ++ ","
                ++ confString.strokeColor
                ++ ","
                ++ confString.canvasColor
                ++ ","
                ++ confString.colorCombination
                ++ "_"
    in
    Html.div []
        [ Html.node "style" [] [ Html.text """
@import url('https://fonts.googleapis.com/css?family=Source+Sans+Pro');
body {
    font-family: 'Source Sans Pro', sans-serif;
    margin: 0;
}

a {
    display: inline-block;
    padding: 0 4px;
}
button {
    font-size: 16px;
    border-radius: 5px;
    margin: 2px;
    background-color: #eee;
    cursor: pointer;
}
button:focus {
    outline: 0px;
    border: 1px solid #06f;
}
th {
    font-weight: normal;
    text-align: right;
    vertical-align: top;
}
""" ]
        , Html.h1 [ Html.Attributes.style [ ( "text-align", "center" ) ] ] [ Html.text "Tangram" ]
        , Html.div [ Html.Attributes.style [ ( "padding", toString margin ++ "px" ) ] ]
            [ Html.table []
                [ Html.tr []
                    [ Html.th [] [ Html.text "Canvas" ]
                    , Html.td []
                        [ Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing Nothing (Just Colors.white) ] [ Html.text "White" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing Nothing (Just Colors.canvasGray) ] [ Html.text "Gray" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing Nothing (Just Colors.darkGray) ] [ Html.text "Dark Gray" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing Nothing (Just Color.orange) ] [ Html.text "Orange" ]
                        ]
                    ]
                , Html.tr []
                    [ Html.th [] [ Html.text "Border" ]
                    , Html.td []
                        [ Html.button [ Html.Events.onClick <| ChangeAspect Nothing (Just 0) Nothing Nothing ] [ Html.text "0" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing (Just 1) Nothing Nothing ] [ Html.text "1" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing (Just 3) Nothing Nothing ] [ Html.text "6" ]
                        ]
                    ]
                , Html.tr []
                    [ Html.th [] [ Html.text "" ]
                    , Html.td []
                        [ Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing (Just <| Colors.darkGray) Nothing ] [ Html.text "Dark Gray" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing (Just <| Colors.elmOrange) Nothing ] [ Html.text "Orange" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect Nothing Nothing (Just <| model.canvasColor) Nothing ] [ Html.text "Canvas" ]
                        ]
                    ]
                , Html.tr []
                    [ Html.th [] [ Html.text "Color" ]
                    , Html.td []
                        [ Html.button [ Html.Events.onClick <| ChangeAspect (Just Elm) Nothing Nothing Nothing ] [ Html.text "Elm 🌳" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect (Just Rainbow) Nothing Nothing Nothing ] [ Html.text "Rainbow 🌈" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect (Just <| Color Colors.darkGray) Nothing Nothing Nothing ] [ Html.text "Dark Gray" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect (Just <| Color Colors.elmOrange) Nothing Nothing Nothing ] [ Html.text "Orange" ]
                        , Html.button [ Html.Events.onClick <| ChangeAspect (Just <| Color Colors.black) Nothing Nothing Nothing ] [ Html.text "Black" ]
                        ]
                    ]
                , Html.tr []
                    [ Html.th [] [ Html.text "Shape" ]
                    , Html.td []
                        [ viewLink
                            (neutralStart
                                ++ "▢,250,200,180_▱,175,125,180_△,200,250,0_▷,150,200,90_▽,200,175,180_◁,275,250,270_◹,275,125,45"
                            )
                            "Square 1"
                        , viewLink
                            (neutralStart
                                ++ "▢,200,150,180_▰,275,225,90_△,200,250,0_▷,150,200,90_▽,150,125,180_◁,225,200,270_◹,275,125,45"
                            )
                            "Square 2"
                        , viewLink
                            (neutralStart
                                ++ "△,184,271,180_◹,109,296,225_▽,234,296,0_◁,259,271,270_▷,152,171,0_▢,217,116,135_▰,252,186,45"
                            )
                            "House"
                        , viewLink
                            (neutralStart
                                ++ "▷,115,178,315_◁,241,160,315_◹,259,213,270_▽,269,284,90_▱,150,249,135_△,187,92,0_▢,115,320,135"
                            )
                            "A"
                        , viewLink
                            (neutralStart
                                ++ "▷,113,78,315_△,111,288,226_◹,113,184,270_▢,183,183,135_▽,243,184,90_◁,243,84,90_▱,243,259,90"
                            )
                            "B"
                        , viewLink
                            (neutralStart
                                ++ "▷,128,182,270_△,113,287,225_▽,203,132,90_◹,149,356,180_▱,219,357,135_▢,253,286,135_◁,232,100,45"
                            )
                            "C"
                        ]
                    ]
                , Html.tr []
                    [ Html.th [] [ Html.text "Paradoxes" ]
                    , Html.td []
                        [ if model.counter % 2 == 0 then
                            viewToggleLink
                                (neutralStart
                                    ++ "◁,219,35,0_▢,219,95,135_△,169,231,270_▰,94,206,0_▷,169,331,90_◹,194,406,135_▽,94,280,270"
                                )
                                "Monk 1 ⥁"
                          else
                            viewToggleLink
                                (neutralStart
                                    ++ "◁,219,35,0_▢,219,95,135_▷,184,236,135_△,184,306,45_▰,94,206,0_◹,144,386,225_▽,159,464,135"
                                )
                                "Monk 2 ⥁"
                        , if model.counter % 3 == 1 then
                            viewToggleLink
                                (neutralStart
                                    ++ "▷,199,57,315_◹,188,188,135_◁,238,163,90_▱,188,238,0_▢,113,163,0_△,128,57,45_▽,113,238,0"
                                )
                                "Cup 1 ⥁"
                          else if model.counter % 3 == 2 then
                            viewToggleLink
                                (neutralStart
                                    ++ "▷,199,57,315_◁,238,163,90_▢,113,163,0_△,128,57,45_▽,188,164,270_◹,198,235,0_▱,127,235,135"
                                )
                                "Cup 2 ⥁"
                          else
                            viewToggleLink
                                (neutralStart
                                    ++ "▱,96,46,180_▽,121,96,180_▷,171,121,270_◹,246,46,315_◁,246,171,90_▢,121,171,0_△,171,221,0"
                                )
                                "Cup 3 ⥁"
                        , if model.counter % 2 == 0 then
                            viewToggleLink
                                (neutralStart
                                    ++ "▢,69,68,225_▱,140,103,225_▷,281,138,135_◹,200,98,315_△,352,138,225_▽,635,148,0_◁,521,148,0"
                                )
                                "Loch Ness 1 ⥁"
                          else
                            viewToggleLink
                                (neutralStart
                                    ++ "▢,69,68,225_▱,140,103,225_◹,200,148,225_▷,275,123,180_△,375,123,0_◁,538,148,0_▽,325,48,0"
                                )
                                "Loch Ness 2 ⥁"
                        ]
                    ]
                , Html.tr []
                    [ Html.th [] [ Html.text "Actions" ]
                    , Html.td []
                        [ Html.button [ Html.Events.onClick Back ] [ Html.text "↺ Undo ⌘Z" ]
                        , Html.button [ Html.Events.onClick Forward ] [ Html.text "↻ Redo ⇧⌘Z" ]
                        , Html.button [ Html.Events.onClick MoveToOrigin ] [ Html.text "Move Up Left" ]
                        ]
                    ]
                ]

            -- , Html.pre [] [ Html.text <| model.encodedTangram ]
            -- , Html.pre [] [ Html.text <| "Last touched: " ++ toString (lastMoved model.pieces) ]
            ]
        , Html.div
            [ Html.Attributes.style
                [ ( "margin", "0 auto" )
                , ( "background-color", Colors.colorToString model.canvasColor )
                , ( "width", toString (model.windowSize.width - margin * 2) ++ "px" )
                , ( "height", toString (model.windowSize.height - margin * 2) ++ "px" )
                , ( "box-shadow", "inset rgba(0, 0, 0, 0.067) 0 0 20px 4px" )
                , ( "position", "relative" )
                ]
            ]
            [ Html.div
                [ Html.Attributes.style
                    [ ( "position", "absolute" )
                    , ( "pointer-events", "none" )
                    , ( "right", "20px" )
                    , ( "top", "20px" )
                    , ( "font-size", "20px" )
                    , ( "opacity", "0.2" )
                    , ( "text-align", "right" )
                    , ( "background-color", "white" )
                    , ( "padding", "10px" )
                    ]
                ]
                [ Html.text "Drag = Move"
                , Html.br [] []
                , Html.text "Shift-Drag = Rotate"
                , Html.br [] []
                , Html.text "⌘Z = Undo"
                , Html.br [] []
                , Html.text "⇧⌘Z = Redo"
                ]
            , scene model
            ]

        --, debugInfo model
        , Html.div [ Html.Attributes.style [ ( "padding", toString margin ++ "px" ) ] ]
            [ Html.div [ class "footerContainer" ] [ madeByLucamug ]
            ]
        , forkMe
        ]


offsetPosition : Decode.Decoder ( Position, Position )
offsetPosition =
    Decode.map2 (,)
        (Decode.map2 Position (Decode.field "pageX" Decode.int) (Decode.field "pageY" Decode.int))
        (Decode.map2 Position (Decode.field "offsetX" Decode.int) (Decode.field "offsetY" Decode.int))


scene : Model -> Html.Html Msg
scene model =
    Svg.svg
        [ VirtualDom.on "mousedown" (Decode.map RectDragStart offsetPosition)
        , width <| toString <| model.windowSize.width - margin * 2
        , height <| toString <| model.windowSize.height - margin * 2
        ]
        (List.map (lazy pieceView) model.pieces)



{--

sceneWithRect : Model -> Html.Html Msg
sceneWithRect model =
    Svg.svg
        [ VirtualDom.on "mousedown" (Decode.map RectDragStart offsetPosition)
        , width <| toString <| model.windowSize.width - 100
        , height <| toString model.windowSize.height
        ]
        (lazy3 background (cursorVal model) model.windowSize.width model.windowSize.height
            :: List.map (lazy pieceView) model.pieces
        )


background : String -> Int -> Int -> Svg.Svg Msg
background cursorV w h =
    Svg.rect
        [ width <| toString w
        , height <| toString h
        , fill "transparent"
        , cursor <| cursorV
        ]
        []
--}


pieceView : ( Name, Piece.Model.Model ) -> Svg.Svg Msg
pieceView ( name, piece ) =
    Piece.view piece |> Html.map (PieceMsg name)


cursorVal : Model -> String
cursorVal model =
    if List.any (Piece.Model.rotating << Tuple.second) model.pieces then
        "crosshair"
    else
        "default"


lastMoved : List Piece.Model.Model -> Maybe Piece.Model.Model
lastMoved listPieces =
    Maybe.map Basics.identity (List.head (List.reverse listPieces))


debugInfo : Model -> Html.Html Msg
debugInfo model =
    Html.div []
        [ Html.text <| "size = " ++ toString model.windowSize
        , Html.text <| "shift = " ++ toString model.keyShiftDown
        , Html.text <| "shift = " ++ toString model.keyControlDown
        , Html.text <| "shift = " ++ toString model.keyCommandDown
        , Html.ul []
            (List.map (\item -> Html.li [] [ (Html.text << toString) item ]) (List.reverse model.pieces))
        ]



-- FORK ME ON GITHUB


forkMe : Html msg
forkMe =
    Html.a [ Html.Attributes.href "https://github.com/lucamug/elm-tangram" ]
        [ Html.img
            [ Html.Attributes.src "https://camo.githubusercontent.com/a6677b08c955af8400f44c6298f40e7d19cc5b2d/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677261795f3664366436642e706e67"
            , Html.Attributes.alt "Fork me on GitHub"
            , Html.Attributes.style
                [ ( "position", "absolute" )
                , ( "top", "0px" )
                , ( "right", "0px" )
                , ( "border", "0px" )
                ]
            ]
            []
        ]



-- MADE BY LUCAMUG


madeByLucamug : Html msg
madeByLucamug =
    Html.a [ class "lucamug", Html.Attributes.href "https://github.com/lucamug" ]
        [ Html.node "style" [] [ Html.text """
        .lucamug{opacity:.4;color:#000;display:block;text-decoration:none}
        .lucamug:hover{opacity:.5}
        .lucamug:hover .lucamugSpin{transform:rotate(0deg);padding:0;position:relative;top:0;}
        .lucamugSpin{color:red ;display:inline-block;transition:all .4s ease-in-out; transform:rotate(60deg);padding:0 2px 0 4px;position:relative;top:-4px;}""" ]
        , Html.text "made with "
        , Html.span [ class "lucamugSpin" ] [ Html.text "凸" ]
        , Html.text " by lucamug"
        ]
