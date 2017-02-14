module Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , TextModel
        , SvgPosition
        , Shape(..)
        , Tool(..)
        , ImageUpload(..)
        , Upload(..)
        , User
        , initialModel
        )

import Mouse
import Dict exposing (Dict)
import Drag exposing (DragAction)


type ImageUpload
    = AwaitingFileSelection SvgPosition
    | AwaitingCompletion Upload


type Upload
    = Running Float
    | Paused Float
    | Errored String
    | Completed String


type alias Model =
    { mouse : MouseModel
    , shapes : Dict Int Shape
    , shapeOrdering : Dict Int Int
    , selectedShapeId : Maybe Int
    , selectedTool : Tool
    , dragAction : Maybe DragAction
    , comparedShape : Maybe Shape
    , user : Maybe User
    , imageUpload : Maybe ImageUpload
    }


type alias User =
    { displayName : String
    , email : String
    , photoUrl : String
    }


type Tool
    = PointerTool
    | RectTool
    | CircleTool
    | TextTool
    | ImageTool


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    , svgPosition : SvgPosition
    , downSvgPosition : SvgPosition
    }


type alias SvgPosition =
    { x : Float
    , y : Float
    }


type Shape
    = Rect RectModel
    | Circle CircleModel
    | Text TextModel


type alias RectModel =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias CircleModel =
    { cx : Float
    , cy : Float
    , r : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias TextModel =
    { x : Float
    , y : Float
    , content : String
    , fontFamily : String
    , fontSize : Int
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


initialModel : Model
initialModel =
    { mouse = initialMouseModel
    , shapes = initialShapes
    , shapeOrdering = Dict.empty
    , selectedShapeId = Nothing
    , selectedTool = PointerTool
    , dragAction = Nothing
    , comparedShape = Nothing
    , user = Nothing
    , imageUpload = Nothing
    }


initialMouseModel : MouseModel
initialMouseModel =
    { position = { x = 0, y = 0 }
    , down = False
    , svgPosition = { x = 0, y = 0 }
    , downSvgPosition = { x = 0, y = 0 }
    }


initialShapes : Dict Int Shape
initialShapes =
    Dict.empty
        |> Dict.insert 1
            (Rect
                { x = 200
                , y = 200
                , width = 200
                , height = 200
                , stroke = "#000000"
                , strokeWidth = 10
                , fill = "#ffffff"
                }
            )
        |> Dict.insert 2
            (Circle
                { cx = 500
                , cy = 200
                , r = 50
                , stroke = "#ff0000"
                , strokeWidth = 10
                , fill = "#00ffff"
                }
            )
