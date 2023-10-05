

extern "C" int gameCards[5][4] = { {0, 1, 2, 3},
								   {0, 1, 2, 3},
								   {4, 5, 6, 7},
								   {8, 9, 9, 8},
	{7, 6, 5, 4} };


extern "C" char tecla;      // Codi ascii corresponent a la tecla pitjada

extern "C" int row;			//fila per a accedir a la matriu gameCards [1..5]
extern "C" char col;		//columna per a accedir a la matriu gameCards [A..D]

extern "C" int rowScreen;	   //fila on volem posicionar el cursor a la pantalla.
extern "C" int colScreen;	   //columna on volem posicionar el cursor a la pantalla.

extern "C" int RowScreenIni;
extern "C" int ColScreenIni;


extern "C" int indexMat; 	//índex per a accedir a la matriu puzzle (index=row*4+col [0..15].

extern "C" char carac;     // codi ascii del caràcter que es vol treure per pantalla.



