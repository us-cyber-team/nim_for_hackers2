/*
    gcc -mno-sse -o main .\main.c
*/
#include <stdio.h>

int main() {
    char sKernel32[] = {
        'k', '\0', 'e', '\0', 'r', '\0', 'n', '\0', 
        'e', '\0', 'l', '\0', '3', '\0', '2', '\0', 
        '.', '\0', 'd', '\0', 'l', '\0', 'l', '\0', 
        '\0', '\0'
    };
    char sLoadLibraryA[] = "LoadLibraryA";
    wprintf(L"[+] sKernel32: %ls\n", sKernel32);
    printf("[+] sLoadLibraryA: %s\n", sLoadLibraryA);
}
