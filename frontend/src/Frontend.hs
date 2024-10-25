{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Frontend where

import Common.Api
import Common.Route
import Control.Lens ((^.))
import Control.Monad
import Control.Monad.IO.Class (liftIO)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Language.Javascript.JSaddle (function, js, js1, jsg, liftJSM, valToNumber)
import Obelisk.Configs
import Obelisk.Frontend
import Obelisk.Generated.Static
import Obelisk.Route
import Reflex.Dom.Core

logInW :: forall t m. MonadWidget t m => m ()
logInW = divClass "container my-4" $ mdo
  isLogin <- switchHold never (_link_clicked <$> switchLink) >>= toggle True
  switchLink <- dyn $ ffor isLogin $ \case
    True -> do
      emailPassW "Log in"
      row . elClass "span" "px-0" $ do
        text "Or "
        link "sign up here"
    False -> do
      back <- row $ link "< Go back"
      emailPassW "Sign up"
      pure back
  pure ()
 where
  row = divClass "row py-2"
  emailPassW :: T.Text -> m (Event t (T.Text, T.Text))
  emailPassW bText = do
    email <- row $ value <$> input "email"
    pass <- row $ value <$> input "password"
    button <- row $ button bText
    -- TODO: validate email and password
    pure $ tagPromptlyDyn (zipDynWith (,) email pass) button
   where
    input t =
      inputElement $
        def
          & inputElementConfig_elementConfig
          . elementConfig_initialAttributes
          .~ ("type" =: t)

-- This runs in a monad that can be run on the client or the server.
-- To run code in a pure client or pure server context, use one of the
-- `prerender` functions.
frontend :: Frontend (R FrontendRoute)
frontend =
  Frontend
    { _frontend_head = do
        el "title" $ text "Obelisk Minimal Example"
        elAttr "script" ("type" =: "application/javascript" <> "src" =: $(static "lib.js")) blank
        elAttr "link" ("href" =: $(static "main.css") <> "type" =: "text/css" <> "rel" =: "stylesheet") blank
        -- TODO serve pico locally
        elAttr "link" ("href" =: "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css" <> "rel" =: "stylesheet") blank
    , _frontend_body = prerender_ blank $ do
        (animationFrameE, fireAnimationFrameE :: Double -> IO ()) <- newTriggerEvent
        display =<< count animationFrameE
        be <- button "woooo"
        display =<< count be
        el "h1" $ text "Welcome to Obelisk!"
        el "p" $ text $ T.pack commonStuff

        dpb <- getPostBuild >>= delay 0.1
        performEvent_ $ ffor dpb $ \_ -> liftJSM $ void $ do
          f <- function $ \_ _ [arg1] -> valToNumber arg1 >>= liftIO . fireAnimationFrameE
          jsg ("window" :: T.Text)
            ^. js ("skeleton_lib" :: T.Text)
            ^. js1
              ("animationHook" :: T.Text)
              f

        elAttr "img" ("src" =: $(static "obelisk.jpg")) blank
        el "div" $ do
          let cfg = "common/example"
              path = "config/" <> cfg
          getConfig cfg >>= \case
            Nothing -> text $ "No config file found in " <> path
            Just bytes -> case T.decodeUtf8' bytes of
              Left ue -> text $ "Couldn't decode " <> path <> " : " <> T.pack (show ue)
              Right s -> text s
        return ()
    }
