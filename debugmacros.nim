import macros

const tmpVar = "__mkDbgStr_tmp__"

proc mkDbgStr(params: NimNode) : seq[NimNode] =
  ## helper proc that creates a local string variable and attaches
  ## the parameters to it.
  ## String literals are simply attached to the local variable,
  ## Variables are attached by name and their conents converted to string.
  var stmtList : seq[NimNode] = @[]
  if len(params) > 0:
    var divider = ""
    # create a temporary variable
    stmtList.add(newNimNode(nnkVarSection).add(
      newIdentDefs(ident(tmpVar), ident("string"), newLit(""))))

    proc append(nodes: varargs[NimNode]) =
      for n in nodes:
        # appends substrings to the temporary variable
        stmtList.add(newCall(newDotExpr(ident(tmpVar), ident("add")), n))

    for par in params:
      if par.kind == nnkStrLit:
        # append string as is
        append(par)
        divider = " "
      else:
        # append variable name and content
        append(newLit(divider), toStrLit(par), newLit(":"), prefix(par, "$"))
        divider = ", "
  result = stmtList


macro dbgEcho*(params:varargs[typed]) : untyped =
  ## Echos the string parameters and variable names with values to the console.
  ## Example:
  ## var x = 123; var y = 456
  ## dbgEcho("Test", x, y)
  ## > Test x:123, y:456
  var stmtList = newNimNode(nnkStmtList)
  let dbgStr = mkDbgStr(params)
  stmtList.add(dbgStr)
  stmtlist.add(newCall(ident("echo"),
    if len(dbgStr) > 0: ident(tmpVar)
    else: newLit("")))

  result = newBlockStmt(stmtlist)

macro dbgAssert*(condition: expr, params:varargs[typed]) : untyped =
  ## Assert macro that prints the names and contents of variables if the
  ## given condition is not true
  var stmtList = newNimNode(nnkStmtList)
  var subStmt = newNimNode(nnkStmtList)
  #[ build statement:
    if not expr:  
      failedAssertImpl(...) <- subStmt
  ]#
  stmtList.
    add(newNimNode(nnkIfStmt).
      add(newNimNode(nnkElifBranch).
        add(prefix(condition, "not")).add(subStmt)))

  let strRepr = mkDbgStr(params)
  let failedCond = newCall(ident("astToStr"), condition)
  subStmt.
    add(strRepr).
    add(newCall(ident("failedAssertImpl"),
      if len(strRepr) > 0: 
        infix(failedCond, "&", 
          infix(newLit(" - "), "&", ident(tmpVar)))
      else:
        failedCond
    ))
  result = newBlockStmt(stmtlist)

when isMainModule:
  ## Example use
  var x = 22; var y = 33
  dbgEcho("Test output",x,y)
  dbgEcho("Single Output")
  
  dbgAssert(x == y, "x and y should be equal", x,y)


