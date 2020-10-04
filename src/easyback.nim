import docopt
import strutils
import os
import json
import sequtils
import sugar
import osproc
import times

type Config = object
    paths: seq[string]
    file: string
    cmd: string
    finish: string

const defaultConfig = Config(
    paths: @[],
    file: "./$y-$m-$d.tar.gz", # file includes path
    cmd: "tar -czvf $f $F"
)

const doc = """
Easy Backup

Usage:
    easyback add <paths>...
    easyback del <paths>...
    easyback conf <key> <value>
    easyback list
    easyback backup

Options:
    -h --help    Show this
    --version    Show version
"""
let configUri = getConfigDir() / "easyback.json"

proc setConfig(config: Config) =
    # TODO add check that you are not just rewritting the file
    writeFile(configUri, $pretty(%*config))

proc getConfig(): Config = 
    ## Gets the config file
    if not fileExists(configUri):
        setConfig(defaultConfig)
        return defaultConfig        
    return parseFile(configUri).to(Config)

proc isParentOf(path1, path2: string): bool =
    ## Checks if the to paths are in the same document tree
    runnableExamples:
        assert isParentOf("/document/backups", "/document") == false # It is a child
        assert isParentOf("/document/2020", "/document/2020/backups") == true # It's a parent
    return path2.startsWith(path1)

when isMainModule:
    var config = getConfig()
    let args = docopt(doc, version = "0.0.1")
    # Add a path to the config
    if args["add"]:
        for pathArg in args["<paths>"]:
            let path = absolutePath($pathArg) # Makes sure the path is absolute
            if config.paths.contains(path):
                echo("Path is already in the config")
                quit(1) # I dont know the correct code
            #[
                Only the top most paths are kept so if you are adding the path
                    /documents/2020/homework
                but the there is already the path
                    /documents/2020
                then it will not be added since you are just duplicating paths
            ]#
            config.paths = collect(newSeq):
                for i in config.paths:
                    if i.isParentOf(path):
                        echo("Path will not be added since it is a child of: " & i)
                        quit(1)
                    elif path.isParentOf(i):
                        continue
                    # Previous statements can both be false
                    i
            config.paths.add(path)
    # Delete a path from the config
    elif args["del"]:
        let paths = collect(newSeq):
            for path in @(args["<paths>"]):
                absolutePath($path)
        config.paths.keepItIf(not paths.contains(it))

    # Backups the selected files
    elif args["backup"]:
        var command = config.cmd
        let date = now()
        command = command.replace("$f", config.file.multiReplace(
            ("$y", $date.year),
            ("$m", $ord(date.month)),
            ("$d", $date.monthDay)
        ))
        command = command.replace("$F", config.paths.join(" "))
        discard execCmd(command)
        if config.finish != "":
            discard execCmd(config.finish)

    # List all the files
    elif args["list"]:
        for path in config.paths:
            echo(path)

    # Edits the config, is broke
    # elif args["conf"]:
        # case toLowerAscii($args["<key>"]):
        # of "file":
            # if args["<value>"]:
                # config.file = $args["<value>"]
            # else:
                # echo(config.file)
        # of "cmd":
            # if args["<value>"]:
                # config.cmd = $args["<value>"]
            # else:
                # echo(config.cmd)
    setConfig(config)    
