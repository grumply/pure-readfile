{-# LANGUAGE CPP #-}
module Pure.ReadFile where

import Pure.Data.Default
import Pure.Data.Lifted
import Pure.Data.Txt as Txt

import Data.ByteString

import Control.Concurrent
import Data.Maybe

#ifdef __GHCJS__
import GHCJS.Buffer
import GHCJS.Marshal.Pure
import JavaScript.TypedArray.ArrayBuffer
#endif

#ifdef __GHCJS__
foreign import javascript unsafe
  "var file = $1.files[$2]; var reader = new FileReader(); reader.readAsArrayBuffer(file); $r = reader;" get_file_reader_js :: Node -> Int -> IO JSV

foreign import javascript unsafe
  "$r = $1.files[$2].name" get_file_name_js :: Node -> Int -> IO Txt

foreign import javascript unsafe
  "$r = $1.result" get_result_js :: JSV -> IO Txt
#endif

getFileAtIndex :: Node -> Int -> IO (Maybe (Txt,ByteString))
getFileAtIndex node n = do
#ifdef __GHCJS__
  rdr <- get_file_reader_js node n
  path <- get_file_name_js node n
  mv <- newEmptyMVar
  onRaw rdr "load" def $ \stop _ -> do
    result <- rdr ..# "result"
    putMVar mv result
    stop
  mresult <- takeMVar mv
  case mresult of
    Nothing -> pure Nothing
    Just (x :: JSV) -> do
      let
        mab :: MutableArrayBuffer
        mab = pFromJSVal x

      ab :: ArrayBuffer <- unsafeFreeze mab

      let
        b :: Buffer
        b = createFromArrayBuffer ab

        bs :: ByteString
        bs  = toByteString 0 Nothing b

      pure $ Just (path,bs)
#else
  return Nothing
#endif

getFile :: Node -> IO (Maybe (Txt,ByteString))
getFile node = getFileAtIndex node 0