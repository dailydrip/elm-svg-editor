module Main exposing (..)

import App exposing (..)
import View exposing (view)
import Html exposing (programWithFlags)
import Model exposing (Model)
import Msg exposing (Msg)
import Update exposing (update)


main : Program () Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
