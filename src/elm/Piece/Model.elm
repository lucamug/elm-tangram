module Piece.Model
    exposing
        ( Model
        , distance
        , getPosition
        , getRotation
        , init
        , move
        , rotating
        , subscriptions
        )

import Colors
import Mouse
import Piece.Types


type alias Model =
    { shape : Piece.Types.Shape
    , position : Piece.Types.Position
    , rotation : Piece.Types.Rotation
    , drag : Maybe Piece.Types.Drag
    , origin : Piece.Types.Position
    , pieceStrokeOffset : Float
    , pieceStrokeColor : Colors.Color
    }


normalizeAngle : Float -> Float
normalizeAngle angle =
    if angle >= 2 * pi then
        normalizeAngle (angle - 2 * pi)
    else if angle < 0 then
        normalizeAngle (angle + 2 * pi)
    else
        angle


init : Piece.Types.Shape -> Piece.Types.Position -> Piece.Types.Rotation -> Float -> Colors.Color -> Model
init shape position rad strokeOffset strokeColor =
    { shape = shape
    , position = position
    , rotation = rad
    , drag = Nothing
    , origin = Piece.Types.Position 0 0
    , pieceStrokeOffset = strokeOffset
    , pieceStrokeColor = strokeColor
    }


getPosition : Model -> Piece.Types.Position
getPosition { position, drag } =
    case drag of
        Just (Piece.Types.Dragging { start, current }) ->
            Piece.Types.Position (position.x + current.x - start.x)
                (position.y + current.y - start.y)

        _ ->
            position


rotating : Model -> Bool
rotating model =
    case model.drag of
        Just (Piece.Types.Rotating _) ->
            True

        _ ->
            False


{-| Calculate current rotation while in rotating state by sampling a point after
the user has dragged out a bit, creating a basis vector relative to the start
point of the drag, then calculating the vactor of the current mouse location
ralative to the drag-start. The rotation is adjusted by the difference of those
vectors, effectively giving a "handle" deterined by the sample vector. Note that
the handle rotation is about the drag-start point, not the rotational center of
the object (not sure how to reconcile mouse coords with the SVG space
coords).
-}
getRotation : Model -> Piece.Types.Rotation
getRotation { position, rotation, drag } =
    case drag of
        Just (Piece.Types.Rotating { start, sample, current }) ->
            case sample of
                Just samplexy ->
                    rotation - relativeRotation position samplexy current

                Nothing ->
                    rotation

        _ ->
            rotation


relativeRotation : Piece.Types.Position -> Piece.Types.Position -> Piece.Types.Position -> Float
relativeRotation start sample current =
    let
        sampleAngle =
            vectorAngle (vectorDiff sample start)

        currentAngle =
            vectorAngle (vectorDiff current start)
    in
    currentAngle - sampleAngle


{-| Angle of point interpreted as vector, in radians
-}
vectorAngle : Piece.Types.Position -> Float
vectorAngle v =
    atan2 (toFloat v.x) (toFloat v.y)


vectorDiff : Piece.Types.Position -> Piece.Types.Position -> Piece.Types.Position
vectorDiff v1 v2 =
    { x = v2.x - v1.x, y = v2.y - v1.y }


subscriptions : Model -> Sub Piece.Types.Msg
subscriptions model =
    case model.drag of
        Nothing ->
            Sub.none

        Just _ ->
            Sub.batch [ Mouse.moves Piece.Types.DragAt, Mouse.ups Piece.Types.DragEnd ]


move : ( Float, Float ) -> Model -> Model
move ( dx, dy ) model =
    let
        newX =
            model.position.x + round dx

        newY =
            model.position.y + round dy
    in
    { model | position = Piece.Types.Position newX newY }


distance : Piece.Types.Position -> Piece.Types.Position -> Float
distance p1 p2 =
    sqrt (toFloat (p1.x - p2.x) ^ 2 + toFloat (p1.y - p2.y) ^ 2)
