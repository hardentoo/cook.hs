module Cook.Catalog.Rkt (
    buildImage
  , signImage
  , trustKey
  , deployImage
  ) where

import System.FilePath

import Cook.Recipe

buildImage :: FilePath -> Recipe f ()
buildImage path = withRecipeName "Rkt.BuildImage" $ do
    withCd (takeDirectory path) $ withSudo $ runProc "acbuild" ["script", takeFileName path]

signImage :: FilePath -> Recipe f ()
signImage path = withRecipeName "Rkt.SignImage" $ do
    withCd (takeDirectory path) $ runProc "gpg" ["--armor", "--output", path <.> "asc", "--detach-sig", path]

trustKey :: FilePath -> Recipe f ()
trustKey path = withRecipeName "Rkt.TrustKey" $ do
    withSudo $ runProc "rkt" ["trust", "--root", path]

deployImage :: FilePath -> Recipe f ()
deployImage = undefined -- XXX
