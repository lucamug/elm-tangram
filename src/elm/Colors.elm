module Colors exposing (..)

import Color
import Color.Convert


type alias Color =
    Color.Color


black : Color
black =
    Color.rgb 0 0 0


elmGreen : Color
elmGreen =
    Color.rgb 141 215 55


elmTurquoise : Color
elmTurquoise =
    Color.rgb 96 181 204


elmOrange : Color
elmOrange =
    Color.rgb 239 165 0


elmGray : Color
elmGray =
    Color.rgb 90 99 120


red : Color
red =
    Color.rgb 255 0 0


white : Color
white =
    Color.white


gray : Color
gray =
    Color.rgb 0x99 0x99 0x99


darkGray : Color
darkGray =
    Color.rgb 0x33 0x33 0x33


canvasGray : Color
canvasGray =
    Color.rgb 0xDD 0xDD 0xDD


colorToString : Color -> String
colorToString color =
    let
        hex =
            Color.Convert.colorToHex color

        short =
            if
                (String.slice 1 2 hex == String.slice 2 3 hex)
                    && (String.slice 3 4 hex == String.slice 4 5 hex)
                    && (String.slice 5 6 hex == String.slice 6 7 hex)
            then
                "#" ++ String.slice 1 2 hex ++ String.slice 3 4 hex ++ String.slice 5 6 hex
            else
                hex
    in
    short


stringToColor : String -> Color
stringToColor string =
    Result.withDefault Color.black
        (Color.Convert.hexToColor string)


colorToNakedString : Color -> String
colorToNakedString color =
    String.dropLeft 1 <| colorToString color
