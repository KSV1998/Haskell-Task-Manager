{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Main where

import Network (makeConnection)
import Options (Options(..), parseArgs)
import Task (printTask, printTitle, listTasks, addTask, completeTask, removeTask, listTodoTasks, listOnPriorityTasks, todoApi, server)

import Database.PostgreSQL.Simple (Connection)
import Network.Wai.Handler.Warp (run)
import Servant (Application, serve)
import System.Environment (getArgs)

main :: IO ()
main = do
  cmdargs <- getArgs
  (Options{..}, args) <- parseArgs cmdargs
  con <- makeConnection optC
  case con of
    Left err -> putStrLn $ "Error :" ++ err
    Right conn ->
      if optA && optB
          then putStrLn "Please choose either interactive mode or api mode"
        else if optA
          then interactiveModeProcess conn args
        else if optB
          then apiModeProcess conn
        else
          putStrLn "Please choose either interactive mode or api mode"

interactiveModeProcess :: Connection -> [String] -> IO ()
interactiveModeProcess _ [] = putStrLn "No Task information/action provided"
interactiveModeProcess conn ["list"] = printTitle *> listTasks conn >>= mapM_ printTask
interactiveModeProcess conn ["todo-list"] = printTitle *> listTodoTasks conn >>= mapM_ printTask
interactiveModeProcess conn ["add", name, description, priority] = addTask conn name description (read priority) >>= either (putStrLn . ("Error: " ++)) (printTask)
interactiveModeProcess conn ["complete", taskId] = completeTask conn taskId >>= either (putStrLn . ("Error: " ++)) (printTask)
interactiveModeProcess conn ["remove", taskId] = removeTask conn taskId >>= either (putStrLn . ("Error: " ++)) (printTask)
interactiveModeProcess conn ["list-on-priority"] = printTitle *> listOnPriorityTasks conn >>= mapM_ printTask
interactiveModeProcess _ _ = putStrLn "Invalid Action. Please try again!!"

apiModeProcess :: Connection -> IO ()
apiModeProcess conn = do
  putStrLn "Starting API Server"
  run 8080 (app conn)

app :: Connection -> Application
app conn = serve todoApi (server conn)
