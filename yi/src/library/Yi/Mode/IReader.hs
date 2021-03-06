{-# LANGUAGE Rank2Types #-}
-- | A simple text mode; it does very little besides define a comment syntax.
-- We have it as a separate mode so users can bind the commands to this mode specifically.
module Yi.Mode.IReader where

import Control.Lens
import Data.Char (intToDigit)
import Yi.Buffer.Misc
import Yi.IReader
import Yi.Keymap
import Yi.Keymap.Keys
import Yi.Core (msgEditor)
import Yi.Modes (anyExtension, fundamentalMode)

abstract :: forall syntax. Mode syntax
abstract = fundamentalMode { modeApplies = anyExtension ["irtxt"],
                             modeKeymap = topKeymapA %~ ikeys }
    where -- Default bindings.
          -- ikeys :: (MonadInteract f Yi.Keymap.Action Event) => f () -> f ()
          ikeys = (choice ([metaCh '`' ?>>! saveAsNewArticle,
                           metaCh '0' ?>>! deleteAndNextArticle] ++
                           map (\x -> metaCh (intToDigit x) ?>>! saveAndNextArticle x) [1..9])
                            <||)

ireaderMode :: Mode syntax
ireaderMode = abstract { modeName = "interactive reading of text" }

ireadMode ::  YiM ()
ireadMode = do withBuffer $ setAnyMode $ AnyMode ireaderMode
               nextArticle
               msgEditor "M-` new; M-0 delete; M-[1-9]: save w/higher priority"
