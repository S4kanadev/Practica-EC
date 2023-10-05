#include <stdio.h>
#include <conio.h>

#include <iostream>
#include <iomanip>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include "Basic_globals.h"

extern "C" {
	// Subrutines en ASM
	void posCurScreen();
	void getMove();
	void moveCursor();
	void moveCursorContinuous();
	void openCard();
	void openCardContinuous();



	void printChar_C(char c);
	int clearscreen_C();
	int printMenu_C();
	int gotoxy_C(int row_num, int col_num);
	char getch_C();
	int printBoard_C(int tries);
	//void continue_C();
}



#define DimMatrixRow 5
#define DimMatrixCol 4



int row = 1;			//fila de la pantalla
char col = 'A';   		//columna actual de la pantalla*/

char carac, tecla;

int opc;
int indexMat;
int rowScreen;
int colScreen;
int RowScreenIni;
int ColScreenIni;

//Mostrar un caràcter
//Quan cridem aquesta funció des d'assemblador el paràmetre s'ha de passar a traves de la pila.
void printChar_C(char c) {
	putchar(c);
}

//Esborrar la pantalla
int clearscreen_C() {
	system("CLS");
	return 0;
}

int migotoxy(int x, int y) { //USHORT x,USHORT y) {
	COORD cp = { y,x };
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cp);
	return 0;
}

//Situar el cursor en una fila i columna de la pantalla
//Quan cridem aquesta funció des d'assemblador els paràmetres (row_num) i (col_num) s'ha de passar a través de la pila
int gotoxy_C(int row_num, int col_num) {
	migotoxy(row_num, col_num);
	return 0;
}


//Imprimir el menú del joc
int printMenu_C() {

	clearscreen_C();
	gotoxy_C(1, 1);
	printf("______________________________________________________________________________\n");
	printf("|                                                                             |\n");
	printf("|                                 MENU MEMORY                                 |\n");
	printf("|_____________________________________________________________________________|\n");
	printf("|                                                                             |\n");
	printf("|                                                                             |\n");
	printf("|                                                                             |\n");
	printf("|                               1. Show Cursor                                |\n");
	printf("|                               2. Move Cursor                                |\n");
	printf("|                               3. Move Cursor Continuous                     |\n");
	printf("|                               4. Open Card                                  |\n");
	printf("|                               5. Open Card Continuous                       |\n");
	printf("|                                                                             |\n");
	printf("|                                                                             |\n");
	printf("|                                                                             |\n");
	printf("|                               0. Exit                                       |\n");
	printf("|                                                                             |\n");
	printf("|_____________________________________________________________________________|\n");
	printf("|                                                                             |\n");
	printf("|                               OPTION:                                       |\n");
	printf("|_____________________________________________________________________________|\n");
	return 0;
}


//Llegir una tecla sense espera i sense mostrar-la per pantalla
char getch_C() {
	DWORD mode, old_mode, cc;
	HANDLE h = GetStdHandle(STD_INPUT_HANDLE);
	if (h == NULL) {
		return 0; // console not found
	}
	GetConsoleMode(h, &old_mode);
	mode = old_mode;
	SetConsoleMode(h, mode & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT));
	TCHAR c = 0;
	ReadConsole(h, &c, 1, &cc, NULL);
	SetConsoleMode(h, old_mode);

	return c;
}


/**
 * Mostrar el tauler de joc a la pantalla. Les li­nies del tauler.
 *
 * Aquesta funcio es crida des de C i des d'assemblador,
 * i no hi ha definida una subrutina d'assemblador equivalent.
 * No hi ha pas de parametres.
 */
void printBoard_C() {
	int i, j, r = 1, c = 25;

	clearscreen_C();
	gotoxy_C(r++, 25);
	printf("===================================");
	gotoxy_C(r++, c); 	      //Ti­tol
	printf("              MEMORY     ");
	gotoxy_C(r++, c);
	gotoxy_C(r++, 25);
	printf("===================================");
	gotoxy_C(r++, c); 	      
	printf("                                   ");
	gotoxy_C(r++, c); 	      //Coordenades
	printf("            A   B   C   D           ");
	for (i = 0; i < DimMatrixRow; i++) {
		gotoxy_C(r++, c);
		printf("\t   +"); 	      // "+" cantonada inicial
		for (j = 0; j < DimMatrixCol; j++) {
			printf("---+");   //segment horitzontal	
		}
		gotoxy_C(r++, c);
		printf("\t%d  |", i + 1);     //Coordenades
		for (j = 0; j < DimMatrixCol; j++) {
			printf(" %c |", ' ');
		}
	}
	gotoxy_C(r++, c);
	printf("\t   +");
	for (j = 0; j < DimMatrixCol; j++) {
		printf("---+");
	}
}

int main(void) {
	opc = 1;
	RowScreenIni = 8;
	ColScreenIni = 37;

	while (opc != '0') {
		printMenu_C();					//Mostrar menú
		gotoxy_C(20, 40);				//Situar el cursor
		opc = getch_C();				//Llegir una opció
		switch (opc) {
		case '1':					//Show cursor
			row = 3;
			col = 'B';
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();			//Mostrar el tauler

			gotoxy_C(20, 37);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			
			posCurScreen();		//Posicionar el cursor a pantalla.

			getch_C();				//Esperar que es premi una tecla
			break;

		case '2':                //Move Cursor
			row = 3;
			col = 'B';
			clearscreen_C();  	 //Esborra la pantalla
			printBoard_C();   	 //Mostrar el tauler.

			posCurScreen();		//Posicionar el cursor a pantalla.
			
			moveCursor();		//Moure el cursor
			
			getch_C();
			gotoxy_C(20, 37);		//Situar el cursor a sota del tauler
			printf("Press any key ");

			getch_C();
			break;

		case '3':				//Move Cursor Continuos
			row = 3;
			col = 'B';
			clearscreen_C();  	 //Esborra la pantalla
			printBoard_C();   	 //Mostrar el tauler.

			posCurScreen();			//Posicionar el cursor a pantalla.
			
			moveCursorContinuous();	//Moure el cursor múltiples cops fins pulsar 's' o 'm'.

			gotoxy_C(20, 37);		//Situar el cursor a sota del tauler
			printf("Press any key ");

			getch_C();
			break;
		
		case '4':				//Open Card
			row = 3;
			col = 'B';
			clearscreen_C();  	 //Esborra la pantalla
			printBoard_C();   	 //Mostrar el tauler.

			posCurScreen();			//Posicionar el cursor a pantalla.
						
			openCard();
			
			gotoxy_C(20, 37);		//Situar el cursor a sota del tauler
			printf("Press any key ");

			getch_C();
			break;

		case '5':				//Open Card Continuous
			row = 3;
			col = 'B';
			clearscreen_C();  	 //Esborra la pantalla
			printBoard_C();   	 //Mostrar el tauler.

			posCurScreen();			//Posicionar el cursor a pantalla.

			openCardContinuous();

			gotoxy_C(20, 37);		//Situar el cursor a sota del tauler
			printf("Press any key ");

			getch_C();
			break;
		}
	}
	gotoxy_C(19, 1);						//Situar el cursor a la fila 19
	return 0;
}