module Options where

import System.Console.GetOpt

data Options = Options
  { optA :: Bool
  , optB :: Bool
  , optC :: String
  } deriving Show

defaultOptions :: Options
defaultOptions = Options
  { optA = False
  , optB = False
  , optC = ""
  }

options :: [OptDescr (Options -> Options)]
options =
  [ Option "i" ["interactive-mode"] (NoArg (\opts -> opts { optA = True })) "interactive mode"
  , Option "a" ["api-mode"] (NoArg (\opts -> opts { optB = True })) "Starts API mode"
  , Option "e" ["encryption-key"] (ReqArg (\value opts -> opts { optC = value }) "encryption key") "Specify a Encryption Key to decrypt Password"
  ]

parseArgs :: [String] -> IO (Options, [String])
parseArgs argv = case getOpt Permute options argv of
  (o, n, []) -> return (foldl (flip id) defaultOptions o, n)
  (_, _, errs) -> ioError (userError (concat errs ++ usageInfo header options))
  where
    header = "Usage: TaskManager [OPTION...] files..."
