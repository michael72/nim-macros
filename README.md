# nim-macros
Helper macros for the nim language written in nim

## debugmacros.nim
Contains helper macros for debugging

Example:
    
```nim
import debugmacros
var x = 11
var y = 22
dbgEcho("Some text", x, y)
dbgAssert(x == y, "x and y should be equal", x,y)
```

yields the output

    Some text x:11, y:22
    Traceback (most recent call last)
    example.nim(6)           example
    system.nim(3389)         failedAssertImpl
    system.nim(3381)         raiseAssert
    system.nim(2534)         sysFatal
    Error: unhandled exception: x == y - x and y should be equal x:11, y:22 [AssertionError]

