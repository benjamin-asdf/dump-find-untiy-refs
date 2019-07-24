import osproc, os, strformat

proc outIfErr( msg: string, errC: int) =
  if errC != 0:
    echo &"exited with code {errC}:\n{msg}"
    quit(0)

if paramCount() == 0:
  echo "Please provide the name of the type you want to search for."
  quit(0);

let findFilesCmd = &"rg -l --no-ignore {paramStr(1)} ./"
echo "cmd is ", findFilesCmd
let (files, errC) = execCmdEx(findFilesCmd)

outIfErr(files,errC)

for item in files:
  echo item
