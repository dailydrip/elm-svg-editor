module Encoder exposing (shapesEncoder)

import Json.Encode as Encode exposing (..)
import Model exposing (Shape(..))
import Dict exposing (Dict)


shapesEncoder : Dict Int Shape -> Value
shapesEncoder shapes =
    dictEncoder shapeEncoder shapes


dictEncoder : (a -> Value) -> Dict comparable a -> Value
dictEncoder enc dict =
    Dict.toList dict
        |> List.map (\( k, v ) -> ( toString k, enc v ))
        |> (::) ( "ignoreme", bool False )
        |> object


shapeEncoder : Shape -> Value
shapeEncoder shape =
    case shape of
        Rect rectModel ->
            object <|
                [ ( "type", string "rect" )
                , ( "x", float rectModel.x )
                , ( "y", float rectModel.y )
                , ( "width", float rectModel.width )
                , ( "height", float rectModel.height )
                , ( "stroke", string rectModel.stroke )
                , ( "strokeWidth", float rectModel.strokeWidth )
                , ( "fill", string rectModel.fill )
                ]

        Circle circleModel ->
            object <|
                [ ( "type", string "circle" )
                , ( "cx", float circleModel.cx )
                , ( "cy", float circleModel.cy )
                , ( "r", float circleModel.r )
                , ( "stroke", string circleModel.stroke )
                , ( "strokeWidth", float circleModel.strokeWidth )
                , ( "fill", string circleModel.fill )
                ]

        Text textModel ->
            object <|
                [ ( "type", string "text" )
                , ( "x", float textModel.x )
                , ( "y", float textModel.y )
                , ( "content", string textModel.content )
                , ( "fontFamily", string textModel.fontFamily )
                , ( "fontSize", int textModel.fontSize )
                , ( "stroke", string textModel.stroke )
                , ( "strokeWidth", float textModel.strokeWidth )
                , ( "fill", string textModel.fill )
                ]
