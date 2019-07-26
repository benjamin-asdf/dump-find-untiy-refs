import osproc, os, strformat, strutils

var unityProjectRoot: string = "./"

proc assetPath(): string =
  result = &"{unityProjectRoot}/Assets"

proc outIfErr( msg: string, errC: int) =
  if errC != 0:
    echo &"exited with code {errC}:\n{msg}"
    quit(0)

proc getUnityGuid(file: string): string =
  let awkcmd = """awk '{print $2}'"""
  let cmd = &"rg --no-ignore guid: {file}.meta | {awkcmd}"
  var (guid, errc) = execCmdEx(cmd)
  outIfErr(guid,errc)
  guid.removeSuffix('\n')
  result = guid


if paramCount() == 0:
  echo "Please provide the name of the type you want to search for."
  quit(0);

let findFilesCmd = &"rg -l --no-ignore {paramStr(1)} ./"
let (files, errC) = execCmdEx(findFilesCmd)

outIfErr(files,errC)

for file in splitLines(files):
  if file != "":
    let guid = getUnityGuid(file)
    if guid.contains('\n'):
      echo "guid contains \'\\n\'", guid
    else:
      let cmd = &"rg -l --no-ignore -e \'guid: {guid}\' {unityProjectRoot}"
      let (usages, errC) = execCmdEx(cmd)
      outIfErr(usages, errC)
      echo "file: ", file, " guid: ", guid, " usages:\n", usages
