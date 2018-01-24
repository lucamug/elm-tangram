module Tangram.Types exposing (..)

import Char exposing (KeyCode)
import Colors
import Mouse
import Piece.Types
import Window


type alias ConfString =
    { id : String
    , strokeOffset : String
    , strokeColor : String
    , canvasColor : String
    , colorCombination : String
    }


type alias PieceString =
    { id : String
    , x : String
    , y : String
    , deg : String
    }


type alias Piece =
    { id : String
    , x : Int
    , y : Int
    , deg : Float
    }


type alias Structure =
    { conf : ConfString, pieces : List PieceString }


type alias Conf =
    { id : Piece.Types.Id
    , strokeOffset : Float
    , strokeColor : Colors.Color
    , canvasColor : Colors.Color
    , colorCombination : ColorCombination
    }


type alias Path =
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


type ColorCombination
    = Elm
    | Color Colors.Color
    | Rainbow


type alias Name =
    String


type alias Position =
    { x : Int, y : Int }


type Msg
    = PieceMsg Name Piece.Types.Msg
    | WindowSize Window.Size
    | KeyDown KeyCode
    | KeyUp KeyCode
    | ChangeAspect (Maybe ColorCombination) (Maybe Float) (Maybe Colors.Color) (Maybe Colors.Color)
    | ChangeLocation String
    | MoveToOrigin
    | RectDragStart ( Position, Position )
    | RectDragAt Position
    | RectDragEnd Position
    | NoOp
    | Back
    | Forward
    | ChangeLocationAndToggle String
    | MousePos ( Mouse.Position, Mouse.Position )
