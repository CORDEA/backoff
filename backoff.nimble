# Package

version     = "0.1"
author      = "Yoshihiro Tanaka"
description = "Implementation of exponential backoff for nim."
license     = "Apache License 2.0"
srcDir      = "src"

# Deps

requires "nim >= 0.18.0"

task test, "Test backoff":
  exec "find src/ -name \"*.nim\" | xargs -I {} nim c -r -d:testing -o:test {}"
  exec "find test/ -name \"*.nim\" | xargs -I {} nim c -r {}"
