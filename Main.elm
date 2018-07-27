module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder, field, succeed)
import WebSocket


-- MODEL


type alias Model =
    { products : List Product
    , wishes : List Product
    }


type alias Product =
    { id : Int
    , name : String
    }

initialModel : Model
initialModel =
    Model [] []


-- UPDATE


type Msg
    = NewProduct (Result String Product)
    | AddWish Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddWish id ->
            let
                maybeProduct =
                    List.head (List.filter (\p -> p.id == id) model.products)
            in
                case maybeProduct of
                    Just product ->
                        if (List.member product model.wishes) then
                            ( model, Cmd.none )
                        else
                            ( { model | wishes = (product :: model.wishes) }, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        NewProduct productResult ->
            case productResult of
                Ok product ->
                    ( { model | products = (product :: model.products) }, Cmd.none )

                Err err ->
                    let
                        _ =
                            Debug.log "error" (toString err)
                    in
                        ( model, Cmd.none )



-- DECODERS


productDecoder : Decoder Product
productDecoder =
    Decode.map2 Product
        (field "id" Decode.int)
        (field "name" Decode.string)


decodeJson : String -> Msg
decodeJson json =
    json
        |> Decode.decodeString productDecoder 
        |> NewProduct



-- SUBSCRIPTIONS


productServer : String
productServer =
    "ws://localhost:8080"


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen productServer decodeJson



-- VIEW


viewProduct : Product -> Html Msg
viewProduct product =
    li [ onClick (AddWish product.id) ] [ text product.name ]


viewWish : Product -> Html msg
viewWish product =
    li [] [ text product.name ]


viewProductList products =
    div [ id "products" ]
        [ h2 [] [ text "🎁 Items Selling Right Now..." ]
        , ul [] (List.map viewProduct products)
        ]


viewWishList products =
    div [ id "wishes" ]
        [ h2 [] [ text "🎉 My Wish List!" ]
        , ul [] (List.map viewWish products)
        ]


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ viewProductList (List.take 9 model.products)
        , viewWishList (model.wishes)
        ]


main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
