module Cook.Catalog.Systemd.Container (
    tarRootfs
  , createEmbeddedCookDir
  , embedCabalProgs
  , embedFsTree
  ) where

import System.FilePath

import Cook.Recipe

tarRootfs :: FilePath -> Recipe FilePath
tarRootfs path = withRecipeName "Systemd.Container.TarRootfs" $ do
    let tarball = path <.> "tar.gz"
    runProc "tar" ["cfz", tarball, "-C", path, "."]
    runProc "rm" ["-r", path]
    return tarball

createEmbeddedCookDir :: FilePath -> Recipe ()
createEmbeddedCookDir containerPath = withRecipeName "Systemd.Container.CreateEmbeddedCookDir" $ do
    createFsTree containerPath $
        Dir "cook" (Just 0o755, Just ("root", "root"))
            [ DirEmpty "bin" (Just 0o755, Just ("root", "root"))
            , DirEmpty "conf" (Just 0o755, Just ("root", "root"))
            ]

embedCabalProgs :: FilePath -> Recipe ()
embedCabalProgs containerPath = withRecipeName "Systemd.Container.EmbedCabalProgs" $ do
    runProc "cabal" ["install", "--bindir=" ++ bindir]
  where bindir = containerPath </> "cook/bin"

embedFsTree :: FilePath -> FsTree -> Recipe ()
embedFsTree containerPath fstree = withRecipeName "Systemd.Container.EmbedFsTree" $ do
    createFsTree (containerPath </> "cook") fstree
