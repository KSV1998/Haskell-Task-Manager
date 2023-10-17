module Actions where

import Database.PostgreSQL.Simple (Connection)

type ActionError = String

-- Define a class for database actions
class Actions a where
  getAll :: Connection -> IO [a]
  addRecord :: Connection -> a -> IO (Either ActionError a)
  deleteRecord :: Connection -> String -> IO (Either ActionError a)
  updateRecord :: Connection -> String -> IO (Either ActionError a)
  findRecord :: Connection -> String -> IO (Maybe a)
