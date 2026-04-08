import Lake
open Lake DSL

package «lean» where

@[default_target]
lean_exe «lean» where
  root := `Main
