{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import System.FilePath      (combine, splitFileName)
import Text.Pandoc
import Control.Arrow        ((>>>), second)
import Data.ByteString.Lazy (ByteString)
import Data.Monoid          ((<>))

myConfig :: Configuration
myConfig = defaultConfiguration {
  previewPort = 8800
}

withToc :: WriterOptions
withToc = defaultHakyllWriterOptions {
  writerTableOfContents = True
, writerTemplate = "$toc$\n$body$"
, writerStandalone = True
}

main :: IO ()
main = hakyllWith myConfig $ do
  match "images/*" $ do
    route   idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route   idRoute
    compile compressCssCompiler

  match "*.md" $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  match "albums/*/thumbnailables/*" $ version "thumb" $ do
    route   $ setExtension "png" `composeRoutes`
              prefixFileName "thumb_" `composeRoutes`
              gsubRoute "thumbnailables" (const "")
    compile $ resizeCompiler "80"
  match "albums/*/thumbnailables/*" $ version "scaled" $ do
    route   $ setExtension "png" `composeRoutes`
              gsubRoute "thumbnailables" (const "")
    compile $ resizeCompiler "600"

  match "albums/**.md" $ do
    route $ setExtension "html" `composeRoutes` gsubRoute "rel" (const "")
    compile $ pandocCompilerWith defaultHakyllReaderOptions withToc
      >>= loadAndApplyTemplate "templates/album.html"   postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  create ["archive.html"] $ do
    route idRoute
    compile $ do
      albums <- loadAll "albums/*/*.md" -- Sort on modification time..
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx = listField "posts" postCtx (return posts)          <>
                       listField "albums" postCtx (return albums)        <>
                       constField "title" "Archives"                     <>
                       defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  match "templates/*" $ compile templateCompiler

resizeCompiler :: String -> Compiler (Item ByteString)
resizeCompiler geom = getResourceLBS
      >>= withItemBody (unixFilterLBS "convert" ["-","-resize",geom,"png:-"])

prefixFileName :: String -> Routes
prefixFileName pr = customRoute $ addPrfx pr
  where addPrfx p = toFilePath >>> splitFileName
                    >>> second (p ++) >>> uncurry combine

postCtx :: Context String
postCtx = dateField             "date"                  format <>
          modificationTimeField "modTime" ("%R %p " ++  format)<>
          defaultContext
  where format = "%B %d, %Y"
