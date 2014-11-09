{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
module Main where

import           Codec.Archive.Tar      (extract)
import           Codec.Compression.GZip (decompress)
import qualified Data.ByteString.Lazy   as BL
import           Data.Char              (toLower)
import           Data.FileEmbed         (embedFile)
import           Data.List              (partition)
import           System.Directory       (getCurrentDirectory)
import qualified System.Directory       as Dir
import           System.Environment     (getArgs)
import           System.FilePath        (takeExtension, (</>))
import           System.Info            (os)
import           System.IO.Temp         (withSystemTempDirectory)
import           System.Process         (callProcess)

tarGz :: BL.ByteString
tarGz = BL.fromStrict $(embedFile "data.tar.gz")

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
    let tar = tmp </> "data.tar"
    BL.writeFile tar $ decompress tarGz
    extract tmp tar
    let extracted = tmp </> "data"

    Dir.setCurrentDirectory extracted
    let exe = if null c3 then "MagmaCompiler.exe" else "MagmaCompilerC3.exe"
    if os == "mingw32"
      then callProcess exe argv''
      else callProcess "wine" $ exe : argv''

  Dir.setCurrentDirectory wd
