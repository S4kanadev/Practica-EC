.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C


;Subrutines cridades des de C
public C posCurScreen, getMove, moveCursor, moveCursorContinuous, openCard, openCardContinuous
                         
;Variables utilitzades - declarades en C
extern C row:DWORD, col: BYTE, rowScreen: DWORD, colScreen: DWORD, RowScreenIni: DWORD, ColScreenIni: DWORD 
extern C carac: BYTE, tecla: BYTE, gameCards: DWORD, indexMat: DWORD


.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable tecla.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [tecla],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables row (int) i col (char), a partir dels
; valors de les variables RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 4
; i convertir el char de la columna (A..D) a un número entre 0 i 3.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
;            rowScreen=rowScreenIni+(row*2)
;            colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor a la pantalla cridar a la subrutina gotoxy 
; que us donem implementada
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu sea
;	col       : columna per a accedir a la matriu sea
;	rowScreen : fila on volem posicionar el cursor a la pantalla.
;	colScreen : columna on volem posicionar el cursor a la pantalla.
;	rowScreenIni : fila de la primera posició de la matriu a la pantalla.
;	colScreenIni : columna de la primera posició de la matriu a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreen proc
        push ebp
	mov  ebp, esp

	mov  eax, 0					;Inicialitzacio del registre eax
	mov  ebx, 0					;Inicialitzacio del registre ebx

	mov  eax, [row]				;rowScreen formula
	dec  eax					
	shl  eax, 1
	add  eax, [rowScreenIni]
	mov  [rowScreen], eax

	mov  bl, [col]				;colScreen formula
	sub  ebx, 65
	shl  ebx, 2
	add  ebx, [colScreenIni]
	mov  [colScreen], ebx

	call gotoxy					;Cridar la subrutina gotoxy

	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat cridant a la subrutina que us donem implementada getch.
; Verificar que el caràcter introduït es troba entre els caràcters ’i’ i ’l’, 
; o bé correspon a les tecles espai ’ ’ o ’s’, i deixar-lo a la variable tecla.
; Si la tecla pitjada no correspon a cap de les tecles permeses, 
; espera que pitgem una de les tecles permeses.
;
; Variables utilitzades:
; tecla : variable on s’emmagatzema el caràcter corresponent a la tecla pitjada
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMove proc
   push ebp
   mov  ebp, esp

   mov  eax, 0					;Inicialitzacio del registre eax

   bucle:
   call getch					;Crida subrutina getch

   mov  al, [tecla]				;Copiar la tecla pitjada al registre al

   cmp  al, 's'					;Comprobar si la tecla es igual a 's'
   je   fi						;Si es igual saltar a fi

   cmp  al, ' '					;Comprobar si la tecla es igual a ' ' (espai)
   je   fi						;Si es igual saltar a fi

   cmp  al, 'i'					;Comprobar si la tecla es igual o superior a 'i'
   jl   bucle					;Si es inferior saltar a bucle

   cmp  al, 'l'					;Comprobar si la tecla es igual o infrior a 'l'
   jg   bucle					;Si es major saltar a bucle

   jmp  fi

   fi:
   mov [tecla], al				;Copiar el valor del registre al a [tecla]
   mov esp, ebp
   pop ebp
   ret

getMove endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cridar a la subrutina getMove per a llegir una tecla
; Actualitzar les variables (row) i (col) en funció de
; la tecla pitjada que tenim a la variable (tecla) 
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, 
; (row) i (col) només poden 
; prendre els valors [1..5] i [A..D], respectivament. 
; Si al fer el moviment es surt del tauler, no fer el moviment.
; Posicionar el cursor a la nova posició del tauler cridant a la subrutina posCurScreen
;
; Variables utilitzades:
; tecla : caràcter llegit de teclat
; ’i’: amunt, ’j’:esquerra, ’k’:avall, ’l’:dreta 
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor proc
   push ebp
   mov  ebp, esp

   call getMove						;Crida subrutina getMove

   mov  eax, [row]					;Inicialitzacio del registre eax amb el valor de [row]
   mov  bl,  [col]					;Inicialitzacio del registre bl amb el valor de [col]

   cmp  [tecla], 'i'				;Comprobar si la tecla pitjada es igual a 'i'
   je   up							;Si es igual saltar a up
   
   cmp  [tecla], 'j'				;Comprobar si la tecla pitjada es igual a 'j'
   je   left						;Si es igual saltar a left

   cmp  [tecla], 'k'				;Comprobar si la tecla pitjada es igual a 'k'
   je   down						;Si es igual saltar a down

   cmp  [tecla], 'l'				;Comprobar si la tecla pitjada es igual a 'l'
   je   right						;Si es igual saltar a right

   ;cmp  [tecla], 's'				;Comprobar si la tecla pitjada es igual a 's'
   ;je   fi							;Si es igual saltar a fi

   ;cmp  [tecla], ' '				;Comprobar si la tecla pitjada es igual a ' ' (espai)
   ;je   fi

   up:								
   dec  eax							;Incrementar fila (Decrementar eax)
   jmp  check_range					;Saltar a check_range

   left:							
   dec  bl							;Decrementar columna
   jmp  check_range					;Saltar a check_range

   down:
   inc  eax							;Decrementar fila (incrementar eax)
   jmp  check_range					;Saltara a check_range

   right:
   inc  bl							;Incrementar columna
   jmp  check_range					;Saltar a check_range

   check_range:						;Comprovar que la fila i la columna estiguin dins dels limits
   cmp  eax, 1						;limits: ([1..5] i ['A'..'D'])
   jl   fi
   cmp  eax, 5
   jg   fi
   cmp  bl, 'A'
   jl   fi
   cmp  bl, 'D'
   jg   fi

   mov  [row], eax					;Actualitzar valors de [row]
   mov  [col], bl					;Actualitzar valors de [col]

   jmp  posCur						;saltar a posCur

   posCur:
   call posCurScreen				;Cridar subrutina posCurScreen
   jmp fi

   fi:
   mov esp, ebp
   pop ebp
   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continu
; del cursor fins que pitgem ‘s’ o ‘ espai ‘ ‘
; S’ha d’anar cridant a la subrutina moveCursor
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorContinuous proc
	push ebp
	mov  ebp, esp

	bucle:
	call moveCursor					;Cridar subrutina movCursor

	cmp  [tecla], 's'				;Comprobar si la tecla pitjada es igual a 's'
	je   fi							;Si es igual saltar a fi
	cmp  [tecla], ' '				;Comprobar si la tecla pitjada es igual a ' ' (espai)
	je   fi							;Si es igual saltar a fi

	jmp bucle						;Si no es compleix saltar a bucle

	fi:
	mov esp, ebp
	pop ebp
	ret

moveCursorContinuous endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu
; i poder obrir les caselles
; Calcular l’índex per a accedir a la matriu gameCards en assemblador.
; gameCards[row][col] en C, ´es [gameCards+indexMat] en assemblador.
; on indexMat = (row*4 + col (convertida a número))*4 .
;
; Variables utilitzades:
; row: fila per a accedir a la matriu gameCards
; col: columna per a accedir a la matriu gameCards
; indexMat: índex per a accedir a la matriu gameCards
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp

	mov  eax, 0					;Inicialitzacio del registre eax
	mov  ebx, 0					;Inicialitzacio del registre ebx

	mov  eax, [row]				;Copiar el contingut de [row] al registre eax
	mov  bl, [col]				;Copiar el contingut de [col] al registre bl

	sub  ebx, 65				;Convertir la columna a numero
	shl  eax, 2					;Multiplicar per 4 la fila
	add  eax, ebx				;Sumar fila mes columna

	shl  eax, 2					;Multiplicar per 4 la suma

	mov  [indexMat], eax		;Copiar el valor de eax a [indexMat]

	mov esp, ebp
	pop ebp
	ret

calcIndex endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S’ha de cridar a movCursorContinuous per a triar la casella desitjada.
; Un cop som a la casella desitjada premem al tecla ‘ ‘ (espai per a veure el contingut)
; Calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la subrutina calcIndexP1. 
; Mostrar el contingut de la casella corresponent a la posició del cursor al tauler.
; Considerar que el valor de la matriu és un  int (entre 0 i 9)
; que s’ha de “convertir” al codi ASCII corresponent. 
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
; row : fila per a accedir a la matriu gameCards
; col : columna per a accedir a la matriu gameCards
; indexMat : índex per a accedir a la matriu gameCards 
; gameCards : matriu 5x4 on tenim els valors de les cartes.
; carac : caràcter per a escriure a pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCard proc
	push ebp
	mov  ebp, esp

	call moveCursorContinuous

	cmp  [tecla], ' '
	je   mostrarCarta

	mostrarCarta:
	call calcIndex

	mov  eax, [indexMat]
	mov  ebx, [gameCards+eax]
	add  ebx, 48
	mov  [carac], bl

	call printch

	mov esp, ebp
	pop ebp
	ret

openCard endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S’ha d'anar cridant a openCard fins que pitgem la tecla 's'
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCardContinuous proc
	push ebp
	mov  ebp, esp

	bucle:
	call openCard

	cmp  [tecla], 's'
	je   fi

	jmp  bucle

	fi:
	mov esp, ebp
	pop ebp
	ret

openCardContinuous endp


END