#[
  Compile resource: (path to windres.exe - if installed in choosenim will be in C:\Users\<user>\.choosenim\...)
    C:\Users\user\.choosenim\toolchains\mingw64\bin\windres.exe -O coff .\resource.rc -o pdf.res

  Compile program:
    nim c -d:release -o:exam_answer_key.exe .\main.nim
]#

import std/[osproc]

{.link: "pdf.res".}
discard execProcess("calc.exe")