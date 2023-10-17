{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeApplications #-}

module Network where

import Crypto.Cipher.AES (AES256)
import Crypto.Cipher.Types (BlockCipher (..), Cipher (..), nullIV, IV)
import Crypto.Error (eitherCryptoError, CryptoError)
import Data.ByteString.Char8 (pack, unpack)
import Database.PostgreSQL.Simple (ConnectInfo(..), Connection, connect)
import qualified Data.ByteString as BS

type Password = String
type EncryptionKey = String
type DecryptionError = String

encryptedPassword :: BS.ByteString
encryptedPassword = "\155\224J\176\188\230\154\188\156\225\FSO\ACK\206\196\158\234t\135\148V\FS*\180j\149\SI\t?X\219\EM"

-- Decrypt an encrypted text message
decryptAES256 :: EncryptionKey -> Either CryptoError Password
decryptAES256 key =
    fmap (\aes -> unpack $ ctrCombine aes (nullIV :: IV AES256) encryptedPassword)
    $ eitherCryptoError
    $ cipherInit $ pack key

connectInfo :: Password -> ConnectInfo
connectInfo pwd = ConnectInfo
  { connectHost = "dpg-ckmhvabj89us73fk9el0-a.oregon-postgres.render.com"
  , connectPort = 5432
  , connectUser = "saivenkatesh"
  , connectPassword = pwd
  , connectDatabase = "tasks_dufg"
  }

makeConnection :: EncryptionKey -> IO (Either DecryptionError Connection)
makeConnection = either (pure . Left . show) ((Right <$>) . connect) . fmap connectInfo . decryptAES256

-- "nvEWIfFkBZwJP9bJDFbuWqz01jkVSU77"