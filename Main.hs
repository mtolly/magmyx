{-# LANGUAGE TemplateHaskell #-}
module Main where

import           Control.Monad      (forM_)
import qualified Data.ByteString    as B
import           Data.Char          (toLower)
import           Data.FileEmbed     (embedDir)
import           Data.List          (partition)
import           System.Directory   (getCurrentDirectory)
import qualified System.Directory   as Dir
import           System.Environment (getArgs)
import           System.FilePath    (takeExtension, (</>))
import           System.Info        (os)
import           System.IO.Temp     (withSystemTempDirectory)
import           System.Process     (callProcess)

dataFiles :: [(FilePath, B.ByteString)]
dataFiles = $(embedDir "data/")

main :: IO ()
main = do
  argv <- getArgs
  wd <- getCurrentDirectory
  let (c3, argv') = partition (== "-c3") argv
      argv'' = flip map argv' $ \arg ->
        if map toLower (takeExtension arg) `elem` [".rbproj", ".rba"]
          then wd </> arg
          else arg
  withSystemTempDirectory "magmyx" $ \tmp -> do

    Dir.setCurrentDirectory tmp
    Dir.createDirectory "gen"
    forM_ dataFiles $ uncurry B.writeFile
    let exe = if null c3 then "MagmaCompiler.exe" else "MagmaCompilerC3.exe"
    if os == "mingw32"
      then callProcess exe argv''
      else callProcess "wine" $ exe : argv''

  Dir.setCurrentDirectory wd
