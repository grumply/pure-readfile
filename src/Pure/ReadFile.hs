{-# LANGUAGE CPP, DeriveGeneric, DeriveAnyClass #-}
module Pure.ReadFile (ByteTxt(),unsafeByteTxtToTxt,unsafeTxtToByteTxt,getFileAtIndex,getFile,writeByteTxt,readByteTxt,appendByteTxt) where

import Pure.Data.Lifted
import Pure.Data.Txt as Txt
import Pure.Data.JSON

import Data.Hashable
import qualified Data.Text.IO as TIO

import Control.Concurrent
import Data.Maybe
import GHC.Generics
import System.IO

newtype ByteTxt = ByteTxt Txt
  deriving (Generic,ToJSON,FromJSON)

instance Hashable ByteTxt where
  hashWithSalt s (ByteTxt bt) =
    hashWithSalt s bt

unsafeByteTxtToTxt :: ByteTxt -> Txt
unsafeByteTxtToTxt (ByteTxt t) = t

unsafeTxtToByteTxt :: Txt -> ByteTxt
unsafeTxtToByteTxt = ByteTxt

#ifdef __GHCJS__
foreign import javascript unsafe
  "var file = $1.files[$2]; var reader = new FileReader(); reader.readAsBinaryString(file); $r = reader;" get_file_reader_js :: Node -> Int -> IO JSV

foreign import javascript unsafe
  "$r = $1.files[$2].name" get_file_name_js :: Node -> Int -> IO Txt

foreign import javascript unsafe
  "$r = $1.result" get_result_js :: JSV -> IO Txt
#endif

getFileAtIndex :: Node -> Int -> IO (Maybe (Txt,ByteTxt))
getFileAtIndex node n =
#ifdef __GHCJS__
  do
    rdr <- get_file_reader_js node n
    path <- get_file_name_js node n
    mv <- newEmptyMVar
    onRaw rdr "load" (Options False False True) $ \stop _ -> do
      result <- rdr ..# "result"
      putMVar mv result
      stop
    mresult <- takeMVar mv
    case mresult of
      Nothing -> pure Nothing
      Just x -> pure $ Just (path,ByteTxt x)
#else
  return Nothing
#endif

getFile :: Node -> IO (Maybe (Txt,ByteTxt))
getFile node = getFileAtIndex node 0
#ifdef __GHCJS__
readByteTxt :: FilePath -> IO ByteTxt
readByteTxt _ = pure (ByteTxt "")

writeByteTxt :: FilePath -> ByteTxt -> IO ()
writeByteTxt _ _ = pure ()

appendByteTxt :: FilePath -> ByteTxt -> IO ()
appendByteTxt _ _ = pure ()
#else
readByteTxt :: FilePath -> IO ByteTxt
readByteTxt fp = ByteTxt <$> withBinaryFile fp ReadMode TIO.hGetContents

writeByteTxt :: FilePath -> ByteTxt -> IO ()
writeByteTxt fp (ByteTxt bt) = withBinaryFile fp WriteMode (flip TIO.hPutStr bt)

appendByteTxt :: FilePath -> ByteTxt -> IO ()
appendByteTxt fp (ByteTxt bt) = withBinaryFile fp AppendMode (flip TIO.hPutStr bt)
#endif
