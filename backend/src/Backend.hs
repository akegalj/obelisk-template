{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}

module Backend where

import Common.Api
import Common.Route
import Control.Concurrent (forkIO)
import Frontend
import Network.Wai (Application)
import qualified Network.Wai.Handler.Warp as Warp
import Obelisk.Backend
import Servant (Proxy (..), Server, (:<|>) (..))
import qualified Servant as Servant

api :: Proxy Api
api = Proxy

server :: Server Api
server = add :<|> sub
 where
  add x y = return (x + y)
  sub x y = return (x - y)

app :: Application
app = Servant.serve api server

backend :: Backend BackendRoute FrontendRoute
backend =
  Backend
    { _backend_run = \serve -> serve $ const $ return ()
    , _backend_routeEncoder = fullRouteEncoder
    }

mainBackend :: IO ()
mainBackend = do
  -- FIXME: There is almost certainly a better and/or safer way of doing this:
  _ <- forkIO $ Warp.run 8081 app
  -- FIXME: use runBackendWith instead of warp^
  runBackend backend frontend
