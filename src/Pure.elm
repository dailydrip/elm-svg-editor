module Pure
    exposing
        ( button
        , buttonActive
        , buttonDisabled
        , buttonPrimary
        , checkbox
        , controlGroup
        , form
        , formAligned
        , formStacked
        , grid
        , group
        , img
        , input
        , inputRounded
        , menu
        , menuAllowHover
        , menuChildren
        , menuDisabled
        , menuHasChildren
        , menuHeading
        , menuHorizontal
        , menuItem
        , menuLink
        , menuList
        , menuSelected
        , menuScrollable
        , radio
        , table
        , tableBordered
        , tableStriped
        , unit
        )

{-| A set of helpers for Pure CSS

-- Taken from https://github.com/benthepoet/elm-purecss, since the package
-- doesn't say it supports 0.18

@docs button, buttonActive, buttonDisabled, buttonPrimary
    , checkbox, controlGroup, form, formAligned, formStacked
    , grid, group, img, input, inputRounded, menu, menuAllowHover
    , menuChildren, menuDisabled, menuHasChildren, menuHeading
    , menuHorizontal, menuItem, menuLink, menuList, menuSelected
    , menuScrollable, radio, table, tableBordered, tableStriped
    , unit

-}

import String


prefix : String
prefix =
    "pure"


purify : List String -> String
purify classes =
    let
        parts =
            prefix :: classes
    in
        String.join "-" parts


{-| -}
button : String
button =
    purify [ "button" ]


{-| -}
buttonActive : String
buttonActive =
    purify [ "button", "active" ]


{-| -}
buttonDisabled : String
buttonDisabled =
    purify [ "button", "disabled" ]


{-| -}
buttonPrimary : String
buttonPrimary =
    purify [ "button", "primary" ]


{-| -}
checkbox : String
checkbox =
    purify [ "checkbox" ]


{-| -}
controlGroup : String
controlGroup =
    purify [ "control", "group" ]


{-| -}
form : String
form =
    purify [ "form" ]


{-| -}
formAligned : String
formAligned =
    purify [ "form", "aligned" ]


{-| -}
formStacked : String
formStacked =
    purify [ "form", "stacked" ]


{-| -}
grid : String
grid =
    purify [ "g" ]


{-| -}
group : String
group =
    purify [ "group" ]


{-| -}
img : String
img =
    purify [ "img" ]


{-| -}
input : List String -> String
input options =
    purify ("input" :: options)


{-| -}
inputRounded : String
inputRounded =
    purify [ "input-rounded" ]


{-| -}
menu : String
menu =
    purify [ "menu" ]


{-| -}
menuAllowHover : String
menuAllowHover =
    purify [ "menu", "allow", "hover" ]


{-| -}
menuChildren : String
menuChildren =
    purify [ "menu", "children" ]


{-| -}
menuDisabled : String
menuDisabled =
    purify [ "menu", "disabled" ]


{-| -}
menuHasChildren : String
menuHasChildren =
    purify [ "menu", "has", "children" ]


{-| -}
menuHeading : String
menuHeading =
    purify [ "menu", "heading" ]


{-| -}
menuHorizontal : String
menuHorizontal =
    purify [ "menu", "horizontal" ]


{-| -}
menuItem : String
menuItem =
    purify [ "menu", "item" ]


{-| -}
menuLink : String
menuLink =
    purify [ "menu", "link" ]


{-| -}
menuList : String
menuList =
    purify [ "menu", "list" ]


{-| -}
menuSelected : String
menuSelected =
    purify [ "menu", "selected" ]


{-| -}
menuScrollable : String
menuScrollable =
    purify [ "menu", "scrollable" ]


{-| -}
radio : String
radio =
    purify [ "radio" ]


{-| -}
table : String
table =
    purify [ "table" ]


{-| -}
tableBordered : String
tableBordered =
    purify [ "table", "bordered" ]


{-| -}
tableStriped : String
tableStriped =
    purify [ "table", "striped" ]


{-| -}
unit : List String -> String
unit options =
    purify ("u" :: options)
