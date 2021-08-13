/* voc 2.1.0 [2021/07/05]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#ifndef Out__h
#define Out__h

#include "SYSTEM.h"


import BOOLEAN Out_IsConsole;


import void Out_Char (CHAR ch);
import void Out_ConvertL (LONGREAL x, INT16 n, CHAR *d, ADDRESS d__len);
import INT16 Out_Expo (REAL x);
import void Out_Flush (void);
import void Out_Hex (INT64 x, INT64 n);
import void Out_Int (INT64 x, INT64 n);
import void Out_Ln (void);
import void Out_LongReal (LONGREAL x, INT16 n);
import void Out_Open (void);
import void Out_Real (REAL x, INT16 n);
import void Out_RealFix (REAL x, INT16 n, INT16 k);
import void Out_String (CHAR *str, ADDRESS str__len);
import LONGREAL Out_Ten (INT16 e);
import void *Out__init(void);


#endif // Out