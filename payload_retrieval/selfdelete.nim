import winim
import system

const NEW_STREAM = ":uscg"

proc deleteSelf*(): bool =
  ## deletes the current binary and returns true if successful
  var
    szPath: array[MAX_PATH*2, WCHAR]
    delete: FILE_DISPOSITION_INFO
    hFile: HANDLE = INVALID_HANDLE_VALUE
    pRename: PFILE_RENAME_INFO
    newStream: LPWSTR = newWideCString(NEW_STREAM)
    sRename: SIZE_T = cast[SIZE_T](sizeof(FILE_RENAME_INFO) + sizeof(newStream))
  pRename = cast[PFILE_RENAME_INFO](HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, sRename))
  if cast[int](pRename) == 0:
    return false
  ZeroMemory(szPath.addr, sizeof(szPath))
  ZeroMemory(delete.addr, sizeof(FILE_DISPOSITION_INFO))
  delete.DeleteFile = TRUE
  pRename.FileNameLength = cast[DWORD](sizeof(newStream))
  RtlCopyMemory(
    cast[PVOID](addr pRename.FileName), 
    newStream, 
    sizeof(newStream)
  )
  if GetModuleFileNameW(
    cast[HMODULE](NULL),
    cast[LPWSTR](addr szPath),
    MAX_PATH * 2
  ) == 0:
    return false
  hFile = CreateFileW(
    cast[LPCWSTR](addr szPath),
    DELETE,
    FILE_SHARE_READ,
    NULL,
    OPEN_EXISTING,
    cast[DWORD](NULL),
    cast[HANDLE](NULL)
  )
  if hFile == INVALID_HANDLE_VALUE:
    return false
  if SetFileInformationByHandle(hFile, cast[FILE_INFO_BY_HANDLE_CLASS](fileRenameInfo), pRename, cast[DWORD](sRename)) == 0:
    return false
  CloseHandle(hFile)
  hFile = CreateFileW(
    cast[LPCWSTR](addr szPath),
    DELETE,
    FILE_SHARE_READ,
    NULL,
    OPEN_EXISTING,
    cast[DWORD](NULL),
    cast[HANDLE](NULL)
  )
  if hFile == INVALID_HANDLE_VALUE and GetLastError() == ERROR_FILE_NOT_FOUND:
    return true
  if hFile == INVALID_HANDLE_VALUE:
    return false
  if SetFileInformationByHandle(hFile, cast[FILE_INFO_BY_HANDLE_CLASS](fileDispositionInfo), delete.addr, cast[DWORD](sizeof(delete))) == 0:
    return false
  CloseHandle(hfile)
  HeapFree(GetProcessHeap(), 0, pRename)
  return true
