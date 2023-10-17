{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Task where

import Actions (Actions(..), ActionError)

import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON, ToJSON, encode)
import Data.ByteString.Lazy.Char8 (pack)
import Data.Functor (($>))
import Data.List (sortOn)
import Data.Time (UTCTime, getCurrentTime)
import Database.PostgreSQL.Simple (Connection, Only(..), query, query_, execute)
import Database.PostgreSQL.Simple.FromRow (FromRow(..), field)
import GHC.Generics (Generic)
import Safe (headMay)
import Servant (Proxy(..), (:>), (:<|>)(..), Get, Post, ReqBody, Capture, Handler, JSON, Server, throwError, ServerError(..))
import Text.Printf (printf)

-- Define a data type for your table
data Task = Task
  { tId :: Int
  , tName :: String
  , tDescription :: String
  , tDateListed :: UTCTime
  , tPriority :: Int
  , tStatus :: String
  } deriving (Eq, Show, Generic, FromJSON, ToJSON)

-- Your list of tasks (initially empty)
type TaskList = [Task]

instance FromRow Task where
  fromRow = Task <$> field <*> field <*> field <*> field <*> field <*> field


instance Actions Task where
  -- Get all records from the table
  getAll conn = query_ conn "SELECT * FROM tasks" :: IO [Task]

  -- Add a new record to the table
  addRecord conn record = do
    findRecord @Task conn (tName record) >>= \case
      Just _ -> pure $ Left "Task Already Exists. Please complete and remove to add again!!"
      Nothing -> do
        _ <- execute conn "INSERT INTO tasks (title, description, priority, datelisted, status) VALUES (?, ?, ?, now(), 'todo')" (tName record, tDescription record, tPriority record)
        findRecord conn (tName record) >>= (\a -> pure $ maybe (Left "Task creation Failed. Try Creating again or Just relax !!") Right a)

  -- Delete a record from the table by Title
  deleteRecord conn name = do
    findRecord @Task conn name >>= \case
      Nothing -> pure $ Left "Kudos, That task is already completed and removed!!"
      Just a -> execute conn "DELETE FROM tasks WHERE name = ?" (Only name) $> Right a

  -- Update a record in the table by Title
  updateRecord conn name = do
    findRecord  @Task conn name >>= \case
      Nothing -> return $ Left "Not able to find the task. Either you have removed it or never added it!!"
      Just tsk -> if tStatus tsk == "complete" then return $ Left "Kudos, That task is already completed!!" else do
        _ <- execute conn "UPDATE tasks SET status = 'complete' WHERE title = ?" (Only name)
        findRecord conn name >>= (pure . maybe (Left "Task updation Failed. Try Updating again or Just relax !!") Right)

  -- Find a record in the table by Title
  findRecord conn name = do
    result <- query conn "SELECT * FROM tasks WHERE title = ?" (Only name) :: IO [Task]
    return $ headMay result

-- Add a task to the list
addTask :: Connection -> String -> String -> Int -> IO (Either ActionError Task)
addTask conn title_ description_ priority_ = do
    utc <- getCurrentTime
    addRecord conn (Task 0 title_ description_ utc priority_ "todo")

-- List all tasks
listTasks :: Connection -> IO [Task]
listTasks = getAll

listTodoTasks :: Connection -> IO [Task]
listTodoTasks conn = do
  tasks <- getAll conn
  return $ filter (\tsk -> tStatus tsk == "todo") tasks

listOnPriorityTasks :: Connection -> IO [Task]
listOnPriorityTasks conn = do
  tasks <- getAll conn
  return $ reverse $ sortOn (\tsk -> ((tPriority tsk) * (-1), tDateListed tsk)) tasks

printTask :: Task -> IO ()
printTask task = printf "%-8d %-11s %-20s %-10d %-10s %s\n" (tId task) (tName task) (tDescription task) (tPriority task) (tStatus task) (show $ tDateListed task)

-- Mark a task as completed
completeTask :: Connection -> String -> IO (Either ActionError Task)
completeTask = updateRecord @Task

-- Remove a task from the list
removeTask :: Connection -> String -> IO (Either ActionError Task)
removeTask = deleteRecord @Task

printTitle :: IO ()
printTitle = putStrLn ("id\t Title\t     Description\t  Priority   Status     DateListed")

type API =
  "tasks" :> Get '[JSON] [Task]            -- Get all tasks
  :<|> "todo" :> Get '[JSON] [Task]            -- Get all tasks
  :<|> "prioritytasks" :> Get '[JSON] [Task]            -- Get all tasks
  :<|> "complete" :> Capture "name" String :> Get '[JSON] Task  -- Get a task by ID
  :<|> "remove" :>Capture "name" String :> Get '[JSON] Task  -- Create a new task
  :<|> "add" :> ReqBody '[JSON] TaskAddRequest :> Post '[JSON] Task  -- Create a new task

todoApi :: Proxy API
todoApi = Proxy

server :: Connection -> Server API
server conn = allTasks conn
    :<|> todoTasksHandler conn
    :<|> prioritytasksHandler conn
    :<|> completeTaskHandler conn
    :<|> removeTaskHandler conn
    :<|> addTaskHandler conn
  
todoTasksHandler :: Connection -> Handler [Task]
todoTasksHandler = liftIO . listTodoTasks

prioritytasksHandler :: Connection -> Handler [Task]
prioritytasksHandler = liftIO . listOnPriorityTasks

allTasks :: Connection -> Handler [Task]
allTasks = liftIO . listTasks 

completeTaskHandler :: Connection -> String -> Handler Task
completeTaskHandler conn name =
  liftIO (completeTask conn name) >>=
  either
    (\err -> throwError $ ServerError 404 (show err) (pack name) [("Content-Type", "application/json")])
    return

removeTaskHandler :: Connection -> String -> Handler Task
removeTaskHandler conn name =
  liftIO (removeTask conn name) >>=
  either
    (\err -> throwError $ ServerError 404 (show err) (pack name) [("Content-Type", "application/json")])
    return

addTaskHandler :: Connection -> TaskAddRequest -> Handler Task
addTaskHandler conn req =
  liftIO (addTask conn (title req) (description req) (priority req)) >>=
  either
    (\err -> throwError $ ServerError 404 (show err) (encode req) [("Content-Type", "application/json")])
    return

data TaskAddRequest = TaskAddRequest
  {
    title :: String
  , description :: String
  , priority :: Int
  } deriving (Show, Generic, FromJSON, ToJSON)

