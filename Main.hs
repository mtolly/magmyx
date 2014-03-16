{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Environment (getArgs)
import System.Directory (getCurrentDirectory, setCurrentDirectory)
import Paths_magmyx (getDataFileName)
import Data.Char (toLower)
import System.FilePath (takeExtension, (</>), takeDirectory)
import System.Process (callProcess)
import System.Info (os)
import Data.List (partition)

main :: IO ()
main = do
  argv <- getArgs
  wd <- getCurrentDirectory
  let (c3, argv') = partition (== "-c3") argv
      argv'' = flip map argv' $ \arg ->
        if map toLower (takeExtension arg) `elem` [".rbproj", ".rba"]
          then wd </> arg
          else arg
  exe <- getDataFileName $
    if null c3 then "MagmaCompiler.exe" else "MagmaCompilerC3.exe"
  setCurrentDirectory $ takeDirectory exe
  if os == "mingw32"
    then callProcess exe argv''
    else callProcess "wine" (exe : argv'')

{-
fixProj :: FilePath -> FilePath -> IO FilePath
fixProj f temp = fromDTA f >>= \dta -> case unserialize dta of
  Left e -> error e
  Right proj -> do
    art <- case albumArtFile $ albumArt $ project proj of
      ""   -> return ""
      file -> let file' = temp </> "cover.bmp" in
        copyFile (B8.unpack file) file' >> return (B8.pack file')
    let proj' = proj
          { project = (project proj)
            { albumArt = (albumArt $ project proj)
              { albumArtFile = art
              }
            }
          }
    undefined
-}
