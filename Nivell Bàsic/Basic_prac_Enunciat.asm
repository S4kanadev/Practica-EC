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
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
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
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funci�  printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
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
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
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
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables row (int) i col (char), a partir dels
; valors de les variables RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 4
; i convertir el char de la columna (A..D) a un n�mero entre 0 i 3.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
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
;	rowScreenIni : fila de la primera posici� de la matriu a la pantalla.
;	colScreenIni : columna de la primera posici� de la matriu a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreen proc
        push ebp
	mov  ebp, esp
								;Al no poder accedir M,M utilitzem registres auxiliars
	mov  eax, 0					;Inicialitzacio del registre eax
	mov  ebx, 0					;Inicialitzacio del registre ebx

								;rowScreen formula (rowScreen=rowScreenIni+(row*2))
	mov  eax, [row]				;Carreguem el contingut de la variable [row] a eax
	dec  eax					;Restem 1 perqu� quedi entre 0 i 4 
	shl  eax, 1					;Multipliquem per 2
	add  eax, [rowScreenIni]	;Sumem el valor de eax amb el contingut de la variable [rowScreenIni]
	mov  [rowScreen], eax		;El resultat de eax el guardem a la variable [rowScreen]

								;colScreen formula (colScreen=colScreenIni+(col*4)
	mov  bl, [col]				;Carreguem el contingut de la variable [col] al registre de 8 bits bl
	sub  ebx, 65				;Restem la "A" per obtenir el numemro de columna 
	shl  ebx, 2					;Multipliquem per 4 
	add  ebx, [colScreenIni]	;Sumem el valor de ebx amb el contingut de la variable [colScreenini]
	mov  [colScreen], ebx		;El resultat de ebx al guardem a la variable [colScreen]
								
	call gotoxy					;Cridar la subrutina gotoxy

	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat cridant a la subrutina que us donem implementada getch.
; Verificar que el car�cter introdu�t es troba entre els car�cters �i� i �l�, 
; o b� correspon a les tecles espai � � o �s�, i deixar-lo a la variable tecla.
; Si la tecla pitjada no correspon a cap de les tecles permeses, 
; espera que pitgem una de les tecles permeses.
;
; Variables utilitzades:
; tecla : variable on s�emmagatzema el car�cter corresponent a la tecla pitjada
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMove proc
   push ebp
   mov  ebp, esp

   mov  eax, 0					;Inicialitzacio del registre auxiliar eax

   bucle:
		call getch				;Crida subrutina getch (llegeix caracter)

   mov  al, [tecla]				;Copiar la tecla apretada al registre al (8 bits perque es char)

   cmp  al, 's'					;Comprobar si la tecla es igual a 's'
   je   fi						;Si es igual saltar a fi

   cmp  al, ' '					;Comprobar si la tecla es igual a ' ' (espai)
   je   fi						;Si es igual saltar a fi

   cmp  al, 'i'					;Comprobar si la tecla es igual o superior a 'i'
   jl   bucle					;Si es inferior saltar a bucle

   cmp  al, 'l'					;Comprobar si la tecla es igual o infrior a 'l'
   jg   bucle					;Si es major saltar a bucle

   jmp  fi						;Saltar a fi

   fi:
	   mov [tecla], al			;Copiar el valor del registre al a [tecla]
	   mov esp, ebp
	   pop ebp
	   ret

getMove endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cridar a la subrutina getMove per a llegir una tecla
; Actualitzar les variables (row) i (col) en funci� de
; la tecla pitjada que tenim a la variable (tecla) 
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, 
; (row) i (col) nom�s poden 
; prendre els valors [1..5] i [A..D], respectivament. 
; Si al fer el moviment es surt del tauler, no fer el moviment.
; Posicionar el cursor a la nova posici� del tauler cridant a la subrutina posCurScreen
;
; Variables utilitzades:
; tecla : car�cter llegit de teclat
; �i�: amunt, �j�:esquerra, �k�:avall, �l�:dreta 
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor proc
   push ebp
   mov  ebp, esp

   call getMove						;Crida subrutina getMove (llegeix tecla)

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

   cmp  [tecla], 's'				;Comprobar si la tecla pitjada es igual a 's'
   je   fi							;Si es igual saltar a fi

   cmp  [tecla], ' '				;Comprobar si la tecla pitjada es igual a ' ' (espai)
   je   fi

   up:								
		dec  eax					;Incrementar fila (Decrementar eax)
		jmp  check_range			;Saltar a check_range

   left:							
	   dec  bl						;Decrementar columna
	   jmp  check_range				;Saltar a check_range

   down:
	   inc  eax						;Decrementar fila (incrementar eax)
	   jmp  check_range				;Saltara a check_range

   right:
	   inc  bl						;Incrementar columna
	   jmp  check_range				;Saltar a check_range

   check_range:						;Comprovar que la fila i la columna estiguin dins dels limits
	   cmp  eax, 1					;limits: ([1..5] i ['A'..'D'])
	   jl   fi
	   cmp  eax, 5
	   jg   fi
	   cmp  bl, 'A'
	   jl   fi
	   cmp  bl, 'D'
	   jg   fi

	   mov  [row], eax				;Actualitzar valors de [row]
	   mov  [col], bl				;Actualitzar valors de [col]

	   jmp  posCur					;saltar a posCur 

   posCur:
	   call posCurScreen			;Cridar subrutina posCurScreen (posiciona cursor)
	   jmp fi						;Saltar a fi

   fi:
	   mov esp, ebp
	   pop ebp
	   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continu
; del cursor fins que pitgem �s� o � espai � �
; S�ha d�anar cridant a la subrutina moveCursor
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorContinuous proc
	push ebp
	mov  ebp, esp

	bucle:
		call moveCursor				;Cridar subrutina movCursor

		cmp  [tecla], 's'			;Comprobar si la tecla pitjada es igual a 's'
		je   fi						;Si es igual saltar a fi
		cmp  [tecla], ' '			;Comprobar si la tecla pitjada es igual a ' ' (espai)
		je   fi						;Si es igual saltar a fi

		jmp bucle					;Si no es compleix saltar a bucle

	fi:
		mov esp, ebp
		pop ebp
		ret

moveCursorContinuous endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu
; i poder obrir les caselles
; Calcular l��ndex per a accedir a la matriu gameCards en assemblador.
; gameCards[row][col] en C, �es [gameCards+indexMat] en assemblador.
; on indexMat = ((row-1)*4 + col (convertida a n�mero))*4 .
;
; Variables utilitzades:
; row: fila per a accedir a la matriu gameCards
; col: columna per a accedir a la matriu gameCards
; indexMat: �ndex per a accedir a la matriu gameCards
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp

	mov  eax, 0					;Inicialitzacio del registre eax
	mov  ebx, 0					;Inicialitzacio del registre ebx

	mov  eax, [row]				;Carreguem el contingut de [row] al registre eax
	dec  eax					;La fila es de 1 a 5 i la matriu de 0 a 4 (per aixo decrementem eax)
	mov  bl, [col]				;Carreguem el contingut de [col] al registre de 8 bits bl
								
								;indexMat = (row*4 + col (convertida a n�mero))*4
	sub  ebx, 65				;Convertir la columna a numero restant 'A'
	shl  eax, 2					;Multiplicar per 4 la fila
	add  eax, ebx				;Sumar fila mes columna

	shl  eax, 2					;Multiplicar per 4 la suma

	mov  [indexMat], eax		;El resultat de eax el guardem a la variable [indexMat]

	mov esp, ebp
	pop ebp
	ret

calcIndex endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S�ha de cridar a movCursorContinuous per a triar la casella desitjada.
; Un cop som a la casella desitjada premem al tecla � � (espai per a veure el contingut)
; Calcular la posici� de la matriu corresponent a la
; posici� que ocupa el cursor a la pantalla, cridant a la subrutina calcIndexP1. 
; Mostrar el contingut de la casella corresponent a la posici� del cursor al tauler.
; Considerar que el valor de la matriu �s un  int (entre 0 i 9)
; que s�ha de �convertir� al codi ASCII corresponent. 
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
; row : fila per a accedir a la matriu gameCards
; col : columna per a accedir a la matriu gameCards
; indexMat : �ndex per a accedir a la matriu gameCards 
; gameCards : matriu 5x4 on tenim els valors de les cartes.
; carac : car�cter per a escriure a pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCard proc
	push ebp
	mov  ebp, esp

	mov eax, 0						;Inicialitzacio del registre eax
	mov ebx, 0						;Inicialitzacio del registre ebx

	call moveCursorContinuous		;Cridar subrutina moveCursorContinuous (triar la casella desitjada)

	cmp  [tecla], 's'				;Comprobar que la tecla pitjada sigui igual a ' ' (espai)
	je   fi							;si es igual salta a mostraCarta

	mostrarCarta:
		call calcIndex				;Cridar subrutina calcIndex (accedir a les components de la matriu)

		mov  eax, [indexMat]		;Carreguem el valor de la variable [indexMat] al registre eax
		
		mov  ebx, [gameCards+eax]	;Carreguem el valor de la variable [gameCards+eax] al registre ebx
		add  ebx, 48				;48 = 0 per obtenir el numero al girar la carta
		mov  [carac], bl			;Guardem el resultat obtingut de 8 bits a la variable [carac]

		call printch				;Cridar subrutina printch

	fi: 
		mov esp, ebp
		pop ebp
		ret

openCard endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S�ha d'anar cridant a openCard fins que pitgem la tecla 's'
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCardContinuous proc
	push ebp
	mov  ebp, esp

	bucle:
		call posCurScreen			;Cridar subrutina posCurScreen
		call openCard				;Cridar subrutina openCard

		cmp  [tecla], 's'			;Comprobar que la tecla pitjada sigui igual a 's'
		je   fi						;Si es igual saltar a fi

		jmp  bucle					;Si no es igual, saltar a bucle

	fi:
		mov esp, ebp
		pop ebp
		ret

openCardContinuous endp

END