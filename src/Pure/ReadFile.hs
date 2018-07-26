{-# LANGUAGE OverloadedStrings, CPP #-}
module Pure.ReadFile where

import Pure.Data.Default
import Pure.Data.Lifted
import Pure.Data.Txt

import Control.Concurrent
import Data.Maybe

#ifdef __GHCJS__
foreign import javascript unsafe
  "var file = $1.files[$2]; var reader = new FileReader(); reader.readAsBinaryString(file); $r = reader;" get_file_reader_js :: Node -> Int -> IO JSV

foreign import javascript unsafe
  "$r = $1.result" get_result_js :: JSV -> IO Txt
#endif

getFileAtIndex :: Node -> Int -> IO Txt
getFileAtIndex node n = do
#ifdef __GHCJS__
  rdr <- get_file_reader_js node n
  mv <- newEmptyMVar
  onRaw rdr "load" def $ \stop _ -> do
    result <- rdr ..# "result"
    putMVar mv result
    stop
  mresult <- takeMVar mv
  return (fromMaybe def mresult)
#else
  return ""
#endif

getFile :: Node -> IO Txt
getFile node = getFileAtIndex node 0