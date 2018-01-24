module Piece.Update exposing (update)

import Piece.Model
import Piece.Types exposing (..)


update : Context -> Msg -> Piece.Model.Model -> ( Piece.Model.Model, Cmd c )
update context msg model =
    let
        model_ =
            updateHelp context msg model
    in
    ( model_, Cmd.none )


positionDiff : Position -> Position -> Position
positionDiff origin pos =
    Position (pos.x - origin.x) (pos.y - origin.y)


updateHelp : Context -> Msg -> Piece.Model.Model -> Piece.Model.Model
updateHelp context msg model =
    case msg of
        DragStart ( xyMouse, xySvg ) ->
            let
                -- Determine SVG origin of piece relative to window by comparing
                -- mouse position at time of mousedown to the offset position
                -- from that event. Awful kludge.
                svgOrigin =
                    positionDiff xySvg xyMouse
            in
            if context.shift then
                { model
                    | drag = Just (Rotating { start = xySvg, current = xySvg, sample = Nothing })
                    , origin = svgOrigin
                }
            else
                { model
                    | drag = Just (Dragging { start = xySvg, current = xySvg })
                    , origin = svgOrigin
                }

        DragAt xyMouse ->
            let
                xySvg =
                    positionDiff model.origin xyMouse

                drag =
                    case model.drag of
                        Nothing ->
                            Nothing |> Debug.log "bogus drag when not dragging?"

                        Just (Dragging { start }) ->
                            Just (Dragging { start = start, current = xySvg })

                        Just (Rotating state) ->
                            let
                                sample =
                                    if state.sample == Nothing && Piece.Model.distance state.start xySvg > 2 then
                                        Just xySvg
                                    else
                                        state.sample
                            in
                            Just (Rotating { state | current = xySvg, sample = sample })
            in
            { model | drag = drag }

        DragEnd xy ->
            { model
                | position = Piece.Model.getPosition model |> restrictTo context.windowSize
                , rotation = Piece.Model.getRotation model
                , drag = Nothing
            }


restrictTo : { width : Int, height : Int } -> Position -> Position
restrictTo { width, height } { x, y } =
    { x = clamp 0 width x
    , y = clamp 0 height y
    }
