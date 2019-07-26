import osproc, os, strformat, strutils

# TODO This could be provived as an arg
var unityProjectRoot: string = "./"

var debug: bool = false

proc debugLog(s: string) =
  if debug: echo s

proc assetPath(): string =
  result = &"{unityProjectRoot}Assets"

proc outIfErr(output: string, errC: int) =
  if errC != 0:
    echo &"error code: {errC}\n output:{output}"
    quit(0)

proc trimNewLine(s: var string) =
  s.removeSuffix('\n')


proc getUnityGuid(file: string): string =
  let awkcmd = """awk '{print $2}'"""
  let cmd = &"rg --no-ignore guid: {file}.meta | {awkcmd}"
  debugLog(&"get unity guid... cmd is:\n{cmd}")
  var (guid, errc) = execCmdEx(cmd)
  outIfErr(guid,errc)
  guid.trimNewLine()
  result = guid

proc getDefinitionFiles(s: string): TaintedString =
  let findFilesCmd = &"rg -l --no-ignore {s} {assetPath()}"
  debugLog(&"get definition files... cmd is:\n{findFilesCmd}")
  var (files, errC) = execCmdEx(findFilesCmd)
  outIfErr(files,errC)
  files.trimNewLine()
  result = files


if not existsDir(assetPath()):
  echo "Enter a unity project root first."
  quit(0)

if paramCount() == 0:
  echo "Please provide the name of the type you want to search for."
  quit(0)

if paramCount() > 1 and paramStr(2) == "-d":
  debug = true

let files = getDefinitionFiles(paramStr(1))

for file in splitLines(files):
  if file != "":
    let guid = getUnityGuid(file)
    let cmd = &"rg -l --no-ignore -e \'guid: {guid}\' {assetPath()}"
    let (usages, errC) = execCmdEx(cmd)
    outIfErr(usages, errC)
    for usagePath in splitLines(usages):
      if usagePath != "":
        echo &"{splitfile(file).name} {usagePath}"
  else: echo "Warning! - handled an empty line, should not happen."
