include     windows.inc
include     user32.inc
include     kernel32.inc
include     comctl32.inc
include     advapi32.inc

includelib  user32.lib
includelib  kernel32.lib
includelib  comctl32.lib
includelib  advapi32.lib

include macros.asm

 DlgProc     PROTO   :DWORD,:DWORD,:DWORD,:DWORD
;
.const
 IDD_MAIN        equ 1000
 IDB_EXIT        equ 1001
 IDC_NAME        equ 1002
 IDC_SERIAL      equ 1005
 IDB_GENERATE    equ 1006
 IDB_ABOUT       equ 1007

.data

.data?
 hInstance   dd  ?