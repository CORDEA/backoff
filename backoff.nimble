# Package

version     = "0.2.0"
author      = "Yoshihiro Tanaka"
description = "Implementation of exponential backoff for nim."
license     = "Apache License 2.0"
srcDir      = "src"

# Deps

requires "nim >= 0.18.0"

task test, "Test backoff":
  exec "nim c -r -d:testing --hints:off -o:nimcache/backoff_testing src/backoff.nim"
  exec "nim c -r --hints:off -o:nimcache/tbackoffcalculator test/backoff/tbackoffcalculator.nim"
  exec "nim c -r --hints:off -o:nimcache/tbackoff test/backoff/tbackoff.nim"
