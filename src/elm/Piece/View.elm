module Piece.View
    exposing
        ( Point
        , boundingBox
        , vertices
        , view
        )

import Colors
import Json.Decode as Json
import Piece.Model exposing (Model, getPosition, getRotation)
import Piece.Types exposing (..)
import String
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import VirtualDom


type alias Point =
    ( Float, Float )


view : Model -> Svg Msg
view model =
    let
        realPosition =
            getPosition model

        pos =
            ( toFloat realPosition.x, toFloat realPosition.y )

        { color } =
            shapeInfo model.shape
    in
    Svg.svg [ VirtualDom.on "mousedown" (Json.map DragStart offsetPosition) ]
        [ polygon2 model (vertices model) color pos model.drag ]


{-| Get final vertex locations for the shape, as points.
-}
vertices : Model -> List Point
vertices model =
    let
        { points, scale } =
            shapeInfo model.shape

        realPosition =
            getPosition model

        realRotation =
            getRotation model

        (( px, py ) as position) =
            ( toFloat realPosition.x, toFloat realPosition.y )
    in
    points |> List.map (scalePoint scale >> rotatePoint realRotation >> translatePoint position)


{-| Origin and corner of minimal bounding box.
-}
boundingBox : Float -> List Point -> ( Point, Point )
boundingBox offset vertices =
    let
        ( xs, ys ) =
            List.unzip vertices

        minx =
            List.minimum xs |> Maybe.withDefault 0

        maxx =
            List.maximum xs |> Maybe.withDefault 0

        miny =
            List.minimum ys |> Maybe.withDefault 0

        maxy =
            List.maximum ys |> Maybe.withDefault 0

        --offset =
        -- model.strokeOffset
        -- THIS NEED TO BE FIXED...
        -- I don't know if it has to be model.strokeOffset or 0 is good too
        --1
    in
    ( ( minx - offset, miny - offset )
    , ( maxx + offset, maxy + offset )
    )


{-| Scale and translate the points so that they just fit in a unit box.
-}
normalizeVertices : Float -> List Point -> List Point
normalizeVertices offset vertices =
    let
        ( ( minx, miny ), ( maxx, maxy ) ) =
            boundingBox offset vertices

        scale =
            Basics.max (maxx - minx) (maxy - miny)
    in
    vertices
        |> List.map (translatePoint ( -minx, -miny ))
        |> List.map (scalePoint (1 / scale))


{-| Extract the page and offset positions from the mouse event.
-}
offsetPosition : Json.Decoder ( Position, Position )
offsetPosition =
    Json.map2 (,)
        (Json.map2 Position (Json.field "pageX" Json.int) (Json.field "pageY" Json.int))
        (Json.map2 Position (Json.field "offsetX" Json.int) (Json.field "offsetY" Json.int))


{-| Define the base (unscaled, unrotated) vertices of the shapes. Define each
such that origin is at their 50% point so that rotation is natural. Triangle is
defined with the hypotenuse on the bottom. Square and parallelogram are oriented
as in the default tangram shape.
-}
trianglePoints : List ( Float, Float )
trianglePoints =
    [ ( 0, -0.5 ), ( 1, 0.5 ), ( -1, 0.5 ) ]


squarePoints : List ( Float, Float )
squarePoints =
    [ ( 0, -0.5 ), ( 0.5, 0 ), ( 0, 0.5 ), ( -0.5, 0 ) ]


paraPoints : List ( Float, Float )
paraPoints =
    [ ( 0.25, -0.25 ), ( -0.75, -0.25 ), ( -0.25, 0.25 ), ( 0.75, 0.25 ) ]


paraPointsInverted : List ( Float, Float )
paraPointsInverted =
    [ ( -0.75, 0.25 ), ( 0.25, 0.25 ), ( 0.75, -0.25 ), ( -0.25, -0.25 ) ]


shapeInfo : Shape -> { points : List Point, color : Colors.Color, scale : Float }
shapeInfo shape =
    case shape of
        Triangle color scale ->
            { points = trianglePoints, color = color, scale = scale }

        Square color scale ->
            { points = squarePoints, color = color, scale = scale }

        Parallelogram color scale ->
            { points = paraPoints, color = color, scale = scale }

        ParallelogramInverted color scale ->
            { points = paraPointsInverted, color = color, scale = scale }



{- Do transformations explicitly in Elm rather than using the SVG `transform`
   attribute. My scheme of defining the shapes with origin at their center does
   not seem to place nice with SVG transformation, causing clipping when coords
   are negative.
-}


polygon2 : Model -> List Point -> Colors.Color -> Point -> Maybe Drag -> Svg Msg
polygon2 model vertices color (( px, py ) as position) drag =
    let
        cursorVal =
            -- The cursor should be moved into html
            case drag of
                Just (Dragging _) ->
                    "move"

                Just (Rotating _) ->
                    "crosshair"

                _ ->
                    "pointer"
    in
    Svg.svg []
        [ Svg.polygon
            [ points <| pointsToString vertices
            , fill <| Colors.colorToString color
            , stroke <| Colors.colorToString model.pieceStrokeColor
            , strokeWidth (toString (model.pieceStrokeOffset * 2))
            , strokeLinejoin "round"
            , cursor cursorVal
            ]
            []
        ]


rotatePoint : Float -> Point -> Point
rotatePoint angle ( x, y ) =
    let
        x_ =
            x * cos angle - y * sin angle

        y_ =
            x * sin angle + y * cos angle
    in
    ( x_, y_ )


scalePoint : Float -> Point -> Point
scalePoint factor ( x, y ) =
    ( x * factor, y * factor )


translatePoint : Point -> Point -> Point
translatePoint ( dx, dy ) ( x, y ) =
    ( x + dx, y + dy )


{-| Construct the value needed for the SVG `points` attribute.
-}
pointsToString : List Point -> String
pointsToString list =
    List.map (\( x, y ) -> toString x ++ " " ++ toString y) list |> String.join " "
