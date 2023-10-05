{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
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
import Language.Javascript.JSaddle (function, js, js1, jsg, liftJSM, nextAnimationFrame, valToNumber)
import Obelisk.Configs
import Obelisk.Frontend
import Obelisk.Generated.Static
import Obelisk.Route
import Reflex.Dom.Core

-- This runs in a monad that can be run on the client or the server.
-- To run code in a pure client or pure server context, use one of the
-- `prerender` functions.
frontend :: Frontend (R FrontendRoute)
frontend =
  Frontend
    { _frontend_head = do
        el "title" $ text "Obelisk Minimal Example"
        elAttr "script" ("type" =: "application/javascript" <> "src" =: $(static "lib.js")) blank
        elAttr "link" ("href" =: $(static "main.css") <> "type" =: "text/css" <> "rel" =: "stylesheet") blank,
      _frontend_body = do
        (animationFrameE, fireAnimationFrameE :: Double -> IO ()) <- newTriggerEvent
        display =<< count animationFrameE
        el "h1" $ text "Welcome to Obelisk!"
        el "p" $ text $ T.pack commonStuff

        -- `prerender` and `prerender_` let you choose a widget to run on the server
        -- during prerendering and a different widget to run on the client with
        -- JavaScript. The following will generate a `blank` widget on the server and
        -- print "Hello, World!" on the client.
        --
        -- FIXME: for some reason this doesnt work (seems like it breaks the app)
        --
        -- prerender_ blank $
        --   liftJSM $
        --     void $ do
        --       f <- function $ \_ _ [arg1] -> valToNumber arg1 >>= liftIO . fireAnimationFrameE
        --       jsg ("window" :: T.Text)
        --         ^. js ("skeleton_lib" :: T.Text)
        --         ^. js1
        --           ("animationHook" :: T.Text)
        --           f

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
