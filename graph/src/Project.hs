module Project (Project(..), getProjects) where

import Data.Maybe            (catMaybes)
import System.FilePath.Posix (takeDirectory)
import System.Path           (absNormPath)

data Project = Project
    { searchPaths :: [FilePath]
    , sources     :: [FilePath]
    , lib         :: FilePath
    } deriving (Show)
    
getProjects :: IO [Project]
getProjects = do
    sln <- readFile "toplevel/code/src/solution.sln"
    mapM getProject (lines sln)
  where
    getProject :: FilePath -> IO Project
    getProject f = do
        prj <- readFile f
        let (incs:srcs:lib_:_) = lines prj
            paths = catMaybes $ map (absNormPath (takeDirectory f)) $ words $ incs
        return $ Project paths (words srcs) lib_
