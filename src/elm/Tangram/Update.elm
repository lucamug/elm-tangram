module Tangram.Update exposing (update)

import List.Extra
import Navigation
import Piece.Model
import Piece.Types
import Piece.Update
import Piece.View
import Tangram.Model
import Tangram.Types
import Window


update : Tangram.Types.Msg -> Tangram.Model.Model -> ( Tangram.Model.Model, Cmd Tangram.Types.Msg )
update msg model =
    case msg of
        Tangram.Types.PieceMsg pieceId pieceMsg ->
            let
                pieceDragging =
                    case pieceMsg of
                        Piece.Types.DragStart a ->
                            True

                        Piece.Types.DragAt a ->
                            True

                        Piece.Types.DragEnd a ->
                            False

                ( pieces_, cmds ) =
                    updatePieces pieceId pieceMsg context model.pieces

                newPieces =
                    bringToTop pieceId pieces_

                pathSorted =
                    Tangram.Model.modelToPathSorted model model.pieces

                newPathSorted =
                    Tangram.Model.modelToPathSorted model newPieces

                newPath =
                    Tangram.Model.modelToPath { model | pieces = newPieces }

                context =
                    { shift = model.keyShiftDown, windowSize = model.windowSize }

                newModel =
                    { model
                        | pieces = newPieces
                        , pieceDragging = pieceDragging
                    }

                extraCmd =
                    if pathSorted == newPathSorted then
                        -- Only the order of pieces is changed, no moves
                        Cmd.none
                    else
                        Navigation.newUrl newPath
            in
            newModel ! (extraCmd :: cmds)

        Tangram.Types.WindowSize wsize ->
            let
                width =
                    wsize.width

                height =
                    wsize.height
            in
            ( { model | windowSize = Window.Size width height }, Cmd.none )

        Tangram.Types.KeyDown keycode ->
            if keycode == 16 then
                -- Pressing ⇧
                ( { model | keyShiftDown = True }, Cmd.none )
            else if keycode == 91 || keycode == 224 then
                -- Chrome, Safari = 91, Firefox = 224
                -- Pressing ⌘
                ( { model | keyCommandDown = True }, Cmd.none )
            else if keycode == 90 && model.keyCommandDown && model.keyShiftDown then
                -- Pressing ⇧⌘Z
                model ! [ Navigation.forward 1 ]
            else if keycode == 90 && model.keyCommandDown then
                -- Pressing ⌘Z
                model ! [ Navigation.back 1 ]
            else
                ( model, Cmd.none )

        Tangram.Types.KeyUp keycode ->
            if keycode == 16 then
                ( { model | keyShiftDown = False }, Cmd.none )
            else if keycode == 91 then
                ( { model | keyCommandDown = False }, Cmd.none )
            else
                ( model, Cmd.none )

        Tangram.Types.ChangeAspect maybeColorCombination maybeStrokeOffset maybeStrokeColor maybeCanvasColor ->
            let
                structure =
                    Tangram.Model.modelToStructure model

                conf =
                    Tangram.Model.confStringToConf structure.conf

                newConf =
                    { conf
                        | strokeOffset =
                            case maybeStrokeOffset of
                                Just v ->
                                    v

                                Nothing ->
                                    conf.strokeOffset
                        , strokeColor =
                            case maybeStrokeColor of
                                Just v ->
                                    v

                                Nothing ->
                                    conf.strokeColor
                        , canvasColor =
                            case maybeCanvasColor of
                                Just v ->
                                    v

                                Nothing ->
                                    conf.canvasColor
                        , colorCombination =
                            case maybeColorCombination of
                                Just v ->
                                    v

                                Nothing ->
                                    conf.colorCombination
                    }

                newStructure =
                    { structure | conf = Tangram.Model.confToConfString newConf }

                newPath =
                    Tangram.Model.structureToPath newStructure
            in
            model ! [ Navigation.newUrl newPath ]

        Tangram.Types.ChangeLocation location ->
            ( model, Navigation.newUrl location )

        Tangram.Types.NoOp ->
            model ! []

        Tangram.Types.MoveToOrigin ->
            moveToOrigin model ! []

        Tangram.Types.RectDragStart ( xyMouse, xySvg ) ->
            let
                -- Determine SVG origin of piece relative to window by comparing
                -- mouse position at time of mousedown to the offset position
                -- from that event. Awful kludge.
                svgOrigin =
                    positionDiff xySvg xyMouse

                rectDrag =
                    if model.pieceDragging then
                        Nothing
                    else
                        Just (Tangram.Types.Dragging { start = xySvg, current = xySvg })
            in
            { model
                | rectDrag = rectDrag
            }
                ! []

        Tangram.Types.RectDragAt a ->
            model ! []

        Tangram.Types.RectDragEnd xy ->
            { model | rectDrag = Nothing } ! []

        Tangram.Types.Back ->
            model ! [ Navigation.back 1 ]

        Tangram.Types.Forward ->
            model ! [ Navigation.forward 1 ]

        Tangram.Types.ChangeLocationAndToggle location ->
            { model | counter = model.counter + 1 } ! [ Navigation.newUrl location ]

        Tangram.Types.MousePos ( pagePos, offsetPos ) ->
            { model | pointer = offsetPos } ! []


positionDiff : Tangram.Types.Position -> Tangram.Types.Position -> Tangram.Types.Position
positionDiff origin pos =
    Tangram.Types.Position (pos.x - origin.x) (pos.y - origin.y)


{-| Fold over the list of components and apply the msg to the component piece
with the matching name, collecting the updated models and resulting commands
into separate lists as needed for updating the main model and batching the
commands.
-}
updatePieces :
    Tangram.Types.Name
    -> Piece.Types.Msg
    -> Piece.Types.Context
    -> List ( Tangram.Types.Name, Piece.Model.Model )
    -> ( List ( Tangram.Types.Name, Piece.Model.Model ), List (Cmd Tangram.Types.Msg) )
updatePieces name msg context items =
    let
        updatePiece (( pieceName, piece ) as item) ( items, cmds ) =
            if pieceName == name then
                let
                    ( piece_, cmd ) =
                        Piece.Update.update context msg piece
                in
                ( ( pieceName, piece_ ) :: items, Cmd.map (Tangram.Types.PieceMsg name) cmd :: cmds )
            else
                ( item :: items, cmds )
    in
    List.foldr updatePiece ( [], [] ) items


bringToTop : Tangram.Types.Name -> List ( Tangram.Types.Name, Piece.Model.Model ) -> List ( Tangram.Types.Name, Piece.Model.Model )
bringToTop name items =
    let
        pieceMaybe =
            findPiece name items
    in
    case pieceMaybe of
        Just piece ->
            removePiece name items ++ [ ( name, piece ) ]

        Nothing ->
            items


findPiece : Tangram.Types.Name -> List ( Tangram.Types.Name, Piece.Model.Model ) -> Maybe Piece.Model.Model
findPiece name items =
    List.Extra.find (Tuple.first >> (==) name) items |> Maybe.map Tuple.second


removePiece : Tangram.Types.Name -> List ( Tangram.Types.Name, Piece.Model.Model ) -> List ( Tangram.Types.Name, Piece.Model.Model )
removePiece name items =
    List.filter (Tuple.first >> (/=) name) items


{-| Get bounding box of entire tangram by collecting all vertices of all pieces
and then finding the extremes.
-}
bounds : Tangram.Model.Model -> ( Piece.View.Point, Piece.View.Point )
bounds model =
    List.map (Tuple.second >> Piece.View.vertices) model.pieces
        |> List.concat
        |> Piece.View.boundingBox model.strokeOffset


{-| Move entire tangram as far left and upward as possible while showing all of
all pieces.
-}
moveToOrigin : Tangram.Model.Model -> Tangram.Model.Model
moveToOrigin model =
    moveToPosition { x = 0, y = 0 } model


{-| Move all pieces by same vector so as to put the origin of bounding box at
the given position.
-}
moveToPosition : Piece.Types.Position -> Tangram.Model.Model -> Tangram.Model.Model
moveToPosition { x, y } model =
    let
        ( ( ox, oy ), _ ) =
            bounds model

        vector =
            ( toFloat x - ox, toFloat y - oy )

        movePiece ( name, piece ) =
            ( name, Piece.Model.move vector piece )

        pieces =
            List.map movePiece model.pieces
    in
    { model | pieces = pieces }
