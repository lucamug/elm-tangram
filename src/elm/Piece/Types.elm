module Piece.Types exposing (..)

import Colors exposing (Color)
import Window


type alias Position =
    { x : Int, y : Int }


type alias Id =
    String


type Drag
    = Dragging
        { start : Position
        , current : Position
        }
    | Rotating
        { start : Position
        , current : Position
        , sample : Maybe Position
        }


type Msg
    = DragStart ( Position, Position )
    | DragAt Position
    | DragEnd Position


type alias Scale =
    Float


type alias Rotation =
    Float


type Shape
    = Triangle Color Scale
    | Square Color Scale
    | Parallelogram Color Scale
    | ParallelogramInverted Color Scale


type alias Context =
    { shift : Bool
    , windowSize : Window.Size
    }
