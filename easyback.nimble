# Package

version       = "0.1.0"
author        = "Jake Leahy"
description   = "Enables you to have a list of files that you want backed up. They will be zipped up and placed in a specified folder during backup and can be loaded to somewhere off the computer"
license       = "MIT"
srcDir        = "src"
bin           = @["easyback"]


# Dependencies

requires "nim >= 1.2.0"
requires "docopt == 0.6.7"
