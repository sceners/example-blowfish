;**********************************************************************************
;*************************** Coded by sp0ke  09/2016 ***********************************
;**********************************************************************************
.686P
.model flat,stdcall 
option casemap:none

;================================================================================
;INCLUDES
;================================================================================
include				windows.inc
include				user32.inc
include				kernel32.inc
include				shell32.inc
include				advapi32.inc
include				gdi32.inc
include				comctl32.inc
include				comdlg32.inc
include				masm32.inc
include				macros.asm
include                         mfmplayer\mfmplayer.inc
include                         Crypto_Lib\cryptohash.inc
INCLUDE Crypto_Lib\biglib.inc
INCLUDELIB Crypto_Lib\biglib.lib
include Crypto_Lib\bignum.inc
includelib Crypto_Lib\bignum.lib
includelib			user32.lib
includelib			kernel32.lib
includelib			shell32.lib
includelib			advapi32.lib
includelib			gdi32.lib
includelib			comctl32.lib
includelib			comdlg32.lib
includelib			masm32.lib
includelib 			winmm.lib
includelib                      mfmplayer\mfmplayer.lib
includelib		        Crypto_Lib\cryptohash.lib
include Crypto_Lib\BLOWFISH.asm
include Functions\OTHERS.asm
		
;================================================================================
;PROTOS
;================================================================================
DlgProc		          Proto		:DWORD,:DWORD,:DWORD,:DWORD 
DlgAbout		PROTO :DWORD,:DWORD,:DWORD,:DWORD

 Generate    PROTO   :HWND
 HexToChar   PROTO   :DWORD,:DWORD,:DWORD
 Clean       PROTO
;================================================================================
.data
;================================================================================

szName      db  100h    dup(?)
szSerial    db  100h    dup(?)
Message     dd  20h     dup(?)
hash        dd  20h     dup(?)
hash2       dd  04h     dup(?)
SerPart1    db  30h     dup(?)
SerPart2    db  30h     dup(?)

aTahoma	db 'Lucida Console',0

hFont		    dd 0
number	        dd 0 
szInfoText	db	"All members ,", 10, 13
			db	"MPT T34M, xtx T34M,", 10, 13
			db	"CIN1 TEAM, REPT TEAM", 10, 13
			db	"ARTeam, SND, FFF, ZWT...", 00h
;================================================================================

Caption         db "Example BlowFish",0     

	sFormat_2 					db '%.8X%.8X', 0
	hInstance				dd		0
	dlgname				db		"Blowfish",0
	
	sKeyIn                                  db 05Dh, 0B4h, 03Ch, 03Fh, 0D1h, 05Dh, 07Fh, 0A2h ; =====> You can change the Key
						db 0B3h, 0B1h, 0A3h, 05Fh, 061h, 0EFh, 0B5h, 0BEh
						db 0B9h, 0A9h, 023h, 02Ch, 029h, 03Eh, 026h, 022h
						db 02Ch, 01Fh,0
         buffer2				db		512 dup (0)
         	nCompNameBufferSize	dd		261
	BufferSize				dd		32
	NameBuffer			db		512 dup (0)
	bCipherMode					BOOL 0
	bPadInput					BOOL 0

;================================================================================
.data?  													
;================================================================================ 

	OllyFound 			db ?
	VAlloc 				dd ?
	OProc 				dd ?
	Rpm 				         dd ?
	EProc 				dd ?
	pBuff 				dd ?
	dummy 				dd ?
	temp                                      dd ?



	szInput				db		512 dup(?)
	serr0ot				db 		512 dup(?)
	Buffer				db 		512 dup(?)
	Buffer2				db 		512 dup(?)
	BufferCRC			db 		512 dup(?)	
	SHA256Buffer			db 		512 dup(?)
	lenDataToHash		        dd 		?
	HashBuffer			dd 		?
	HashBufferH			dd 		?
	KeyHasher			dd 		?

	nMusicSize     DWORD      ?
	pMusic         LPVOID     ?
	hBgColor		HBRUSH	?

	serBuffer db 		512 dup(?)	
	serBuffer2				db		1024 dup(?)
	hWin2                    HWND ?
	hBrushBack	 HWND ?
	handle	        dd	?
	ScrollMainDC	HDC	?
	ScrollBackDC	HDC	?
	Tick	        dd	?
	ScrollBitmap	HBITMAP	?
	dword_40CD18	dd	?
	Rect		RECT	<>
	Paint	PAINTSTRUCT	<>
	
;================================================================================
.const 													
;================================================================================
Dialog 			equ		1001
IDC_EDIT1011		equ		1004
IDC_EDIT1015		equ		1010
ReD_SkUlL 		equ 		2000
IDC_EDT_INPUT 	equ		1001
IDC_OUTPUT 		equ            1015
Icon		    equ	1000
IDD_MAIN	    equ	102
IDC_IMAGE1023        equ           1023
IDC_INFO			equ	1006
IDC_STATICTHANK	equ	2025
IDC_ABOUTOK		equ	2026

CR_BACKGROUND equ 00FFFFFFh
CR_STATIC 		equ 00FF0000h
CR_EDIT			equ 000000FFh
;================================================================================
.code 													
;================================================================================
start: 

    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke InitCommonControls
    invoke DialogBoxParam, hInstance, 1001, NULL, addr DlgProc, NULL 
    invoke ExitProcess,eax 
HexLen	macro
	xor	edx, edx
	mov	ecx, 2
	idiv ecx
endm

DecLen	macro
	xor	edx, edx
	mov	ecx, 3
	idiv ecx
endm
DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 

     
    .if uMsg == WM_INITDIALOG
	invoke LoadIcon,hInstance,Icon
	invoke SendMessage,hWnd,WM_SETICON,ICON_SMALL, eax
	invoke SendMessage, eax, EM_SETLIMITTEXT,50,0
	invoke SendMessage,hWnd,WM_SETICON,1,eax
	invoke SetWindowText,hWnd, addr Caption
	Invoke	CreateSolidBrush, hBrushBack
	
	.elseif [uMsg]==WM_MOUSEMOVE
	mov eax,wParam
	cmp eax,1
	je @@MF
	xor eax,eax
	ret
	@@MF:
	invoke ReleaseCapture
	invoke SendMessage,[hWnd],WM_SYSCOMMAND,0F012h,0
	xor eax,eax
	ret
			
	.elseif uMsg == WM_COMMAND
		mov	eax,wParam
		.if eax==1021

	invoke GetDlgItemText,hWnd,1011,addr szInput,sizeof szInput	
			
              
		call BLOWFISH_ENC_RT	
		
	invoke  HexToChar,addr sKeyIn,addr BufferCRC,26

	invoke SetDlgItemText,hWnd,1015,addr _Output
	invoke SetDlgItemText,hWnd,1025,addr BufferCRC

		.elseif ax==1017

;	invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
invoke DialogBoxParam, hInstance, 102, hWnd, addr DlgAbout, 0
	.elseif ax==1020
		invoke	SendMessage		,hWnd,WM_CLOSE,0,0
	.endif     
	.elseif	uMsg == WM_CLOSE
		invoke	EndDialog		,hWnd,0
	.endif  
		xor eax, eax
		ret

DlgProc endp


BLOWFISH_ENC_RT proc hWnd
local _len:dword

;		invoke lstrlen, addr sKeyIn
;		cmp eax, 4
;		jl @invalidKey
;		cmp eax, 56
;		jg @invalidKey

; =======================   Algo ============================================
		invoke lstrlen, addr sKeyIn
		push eax
		push offset sKeyIn
		call Blowfish_SetKey
		invoke RtlZeroMemory, offset bf_tempbuf, sizeof bf_tempbuf-1
		invoke RtlZeroMemory, addr _Output, sizeof _Output

		mov	esi, offset [szInput]
		invoke lstrlen, addr szInput
		mov	ebx, eax
		
	@EncryptLoop:
		push esi
		mov	eax, ebx
		mov	ecx, 8
		xor	edx, edx
		div	ecx
		.if	eax == 0
			mov	eax, edx
		.else
			mov	eax, 8
		.endif

		push eax
		push esi
		call Bit8Prepare

		.if bCipherMode == 1
			push 8
			push offset bf_encryptbuf
			call CipherXor
		.endif

		mov [fixup], 01h
		push offset bf_encryptbuf
		push offset bf_tempbuf
		call Blowfish_Encrypt
		mov [fixup], 00h

		mov esi, offset bf_tempbuf
		mov eax, dword ptr [esi]
		mov edx, dword ptr [esi+4]
		bswap eax
		bswap edx
		invoke wsprintf, addr bf_tempbufout, addr sFormat_2, eax, edx
		invoke lstrcat,  addr _Output, addr bf_tempbufout
		
		pop	esi
		add	esi, 8
		sub	ebx, 8
		cmp	ebx, 0
		jg @EncryptLoop
		call Blowfish_Clear
		invoke lstrlen,  addr _Output
		HexLen
		ret
;
	@invalidKey:	
		;invoke SetDlgItemText, hWindow, IDC_INFO, SADD("Error - The length of the key must be a multiple of 8 between 8 and 56 chars.")
;		invoke SetDlgItemText, hWindow, IDC_INFO, SADD("Error - The length of the key must be between 4 and 56 chars.")
		mov eax, -1
		ret
BLOWFISH_ENC_RT endp
align dword
_rand proc
	mov eax,Tick
	imul eax,eax,0A999h
	add eax,0269EC3h
	mov Tick,eax
	sar eax,010h
	and eax,0FFFFh
	Ret
_rand EndP
align dword
 HexToChar Proc HexValue:DWORD,CharValue:DWORD,HexLength:DWORD
     mov esi,[ebp+8]
     mov edi,[ebp+0Ch]
     mov ecx,[ebp+10h]
     @HexToChar:
     lodsb
     mov ah, al
     and ah, 0fh
     shr al, 4
     add al, '0'
     add ah, '0'
     .if al > '9'
     add al, 'A'-'9'-1
     .endif
     .if ah > '9'
     add ah, 'A'-'9'-1
     .endif
     stosw
     loopd @HexToChar
     Ret
 HexToChar endp
 Clean   Proc
	invoke  RtlZeroMemory,addr szName,sizeof szName
	invoke  RtlZeroMemory,addr szSerial,sizeof szSerial
	invoke  RtlZeroMemory,addr hash,sizeof hash
	invoke  RtlZeroMemory,addr hash2,sizeof hash2  
	invoke  RtlZeroMemory,addr szInput,sizeof szInput
	invoke  RtlZeroMemory,addr SerPart1,sizeof SerPart1
	invoke  RtlZeroMemory,addr SerPart2,sizeof SerPart2
     Ret
 Clean endp
 DlgAbout		proc	hWin	:DWORD,
				uMsg	:DWORD,
				wParam	:DWORD,
				lParam	:DWORD
	.if uMsg == WM_INITDIALOG
		invoke SetDlgItemText, hWin, IDC_STATICTHANK, addr szInfoText
	.elseif uMsg == WM_COMMAND
		.if wParam == IDC_ABOUTOK
			invoke EndDialog,hWin,0
		.endif
	.elseif uMsg == WM_CTLCOLORDLG 
		mov eax, hBgColor
		ret
	.elseif uMsg == WM_CTLCOLORSTATIC 
		invoke SetBkMode, wParam, TRANSPARENT
		invoke SetTextColor, wParam, CR_STATIC
		invoke GetDlgCtrlID, lParam
		Invoke SetBkColor,wParam,CR_BACKGROUND 
		mov eax, hBgColor
		ret
	.elseif	uMsg == WM_CLOSE
		invoke EndDialog,hWin,0
	.endif
	xor	eax,eax
	ret
DlgAbout		endp
end start