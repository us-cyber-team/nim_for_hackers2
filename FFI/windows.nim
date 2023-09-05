{.emit: """
#include <windows.h>
#include <stdio.h>

void popMessageBox() {
  printf("[!] MessageBoxA\n");
  MessageBoxA(0, "MessageboxA Text", "MessageBoxW Title", MB_OK);
  MessageBoxW(0, L"MessageboxW Text", L"MessageBoxW Title", MB_OK);
}
""".}
proc popMessageBox(): void {.importc: "popMessageBox", nodecl.}

popMessageBox()




