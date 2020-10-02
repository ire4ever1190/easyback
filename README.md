# easyback

My server harddrive failed so I made this so I don't lose stuff in future

This allows you to keep a list of files and/or folders that you want to be backed up.
For clarification, when I mean backup, I mean that it creates an archive of the files **you still need to find someplace safe for it**

### How to
first install using nimble
```
nimble install https://github.com/ire4ever1190/easyback
```

then add something
```
~> easyback add ~/Documents/homework
```

you can double check it was added correctly
```
~> easyback list
/home/you/Documents/homework
```

then you can make the archive
```
easyback backup
```

### Config
The config by default is located at ~/.config/easyback.json
you can edit the different values such as the output, command to use, command to run after
