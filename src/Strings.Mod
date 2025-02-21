(*-------------------------------------------------------------
Strings provides a set of operations on strings (i.e., on string constants and character
arrays, both of which contain the character 0X as a terminator). All positions in
strings start at 0.
Strings.Length(s)
  returns the number of characters in s up to and excluding the first 0X.
Strings.Insert(src, pos, dst)
  inserts the string src into the string dst at position pos (0 <= pos <= Length(dst)).
  If pos >= Length(dst), src is appended to dst. If the size of dst is not large enough
  to hold the result of the operation, the result is truncated so that dst is always
  terminated with a 0X.
Strings.Append(s, dst)
  has the same effect as Insert(s, Length(s), dst).
Strings.Delete(s, pos, n)
  deletes n characters from s starting at position pos (0 <= pos < Length(s)).
  If n > Length(s) - pos, the new length of s is pos.
Strings.Replace(src, pos, dst)
  has the same effect as Delete(dst, pos, Length(src)) followed by an Insert(src, pos, dst).
Strings.Extract(src, pos, n, dst)
  extracts a substring dst with n characters from position pos (0 <= pos < Length(src)) in src.
  If n > Length(src) - pos, dst is only the part of src from pos to Length(src) - 1. If the size of
  dst is not large enough to hold the result of the operation, the result is truncated so that
  dst is always terminated with a 0X.
Strings.Copy(src, dst)
  has the same effect as Extract(src, 0, LEN(dst), dst)
Strings.Pos(pat, s, pos)
  returns the position of the first occurrence of pat in s after position pos (inclusive).
  If pat is not found, -1 is returned.
Strings.Cap(s)
  replaces each lower case letter in s by its upper case equivalent.
-------------------------------------------------------------*)

MODULE Strings;
IMPORT Reals, SYSTEM;

TYPE
  REAL = SYSTEM.REAL32;
  LONGREAL = SYSTEM.REAL64;

PROCEDURE Length*(IN s: ARRAY OF CHAR): INTEGER;
VAR i: INTEGER;
BEGIN i := 0; WHILE (i < LEN(s)) & (s[i] # 0X) DO INC(i) END ;
RETURN i END Length;

PROCEDURE Append*(IN extra: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
VAR n1, n2, i: INTEGER;
BEGIN
  n1 := Length(dest); n2 := Length(extra); i := 0;
  WHILE (i < n2) & (i + n1 < LEN(dest)) DO dest[i + n1] := extra[i]; INC(i) END;
  IF i + n1 < LEN(dest) THEN dest[i + n1] := 0X ELSE dest[LEN(dest) - 1] := 0X END
END Append;

PROCEDURE Insert*(IN source: ARRAY OF CHAR; pos: INTEGER; VAR dest: ARRAY OF CHAR);
VAR n1, n2, len, i, j: INTEGER;
BEGIN
  n1 := Length(dest); n2 := Length(source); len := LEN(dest);
  IF pos < 0 THEN pos := 0 END;
  IF pos > n1 THEN Append(source, dest); RETURN END;
  (*--- make room for source*)
  IF pos + n2 < len THEN
    i := n1; j := i + n2; (*move also 0X if it is there*)
    WHILE i >= pos DO
      IF j < len THEN dest[j] := dest[i] END;
      DEC(i); DEC(j)
    END
  END;
  (*--- copy source to dest*)
  i := 0; j := pos;
  WHILE (i < n2) & (j < len) DO
    dest[j] := source[i];
    INC(i); INC(j)
  END;
  IF j >= len THEN dest[len - 1] := 0X END
END Insert;

PROCEDURE Delete*(VAR s: ARRAY OF CHAR; pos, n: INTEGER);
VAR len, i: INTEGER;
BEGIN
  len := Length(s);
  IF pos < 0 THEN pos := 0 ELSIF pos >= len THEN RETURN END;
  IF pos + n < len THEN
    i := pos + n; WHILE i < len DO s[i - n] := s[i]; INC(i) END;
    IF i - n < LEN(s) THEN s[i - n] := 0X END
  ELSE s[pos] := 0X
  END
END Delete;

PROCEDURE Replace*(IN source: ARRAY OF CHAR; pos: INTEGER; VAR dest: ARRAY OF CHAR);
BEGIN
  Delete(dest, pos, pos + Length(source));
  Insert(source, pos, dest)
END Replace;

PROCEDURE Extract*(IN source: ARRAY OF CHAR; pos, n: INTEGER;
    VAR dest: ARRAY OF CHAR);
VAR len, destLen, i: INTEGER;
BEGIN len := Length(source);
  IF pos < 0 THEN pos := 0 ELSIF pos >= len THEN dest[0] := 0X
  ELSE i := 0; destLen := LEN(dest) - 1;
    IF n >= destLen THEN n := destLen - 1 END;
    WHILE (pos + i <= len) & (source[pos + i] # 0X) & (i < n) DO
      IF i < destLen THEN dest[i] := source[pos + i] END;
      INC(i)
    END;
    dest[i] := 0X
  END
END Extract;

PROCEDURE Copy*(IN source: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
VAR i, len: INTEGER;
BEGIN
  IF LEN(source) < LEN(dest) THEN len := LEN(source) - 1
  ELSE len := LEN(dest) - 1
  END;
  i := 0;
  WHILE (i # len) & (source[i] # 0X) DO dest[i] := source[i]; INC(i) END;
  dest[i] := 0X
END Copy;

PROCEDURE Pos*(IN pattern, s: ARRAY OF CHAR; pos: INTEGER): INTEGER;
VAR n1, n2, i, j: INTEGER;
BEGIN
  n1 := Length(s); n2 := Length(pattern);
  IF n2 = 0 THEN RETURN 0 END;
  i := pos;
  WHILE i <= n1 - n2 DO
    IF s[i] = pattern[0] THEN
      j := 1; WHILE (j < n2) & (s[i + j] = pattern[j]) DO INC(j) END;
      IF j = n2 THEN RETURN i END
    END;
    INC(i)
  END;
  RETURN -1
END Pos;

PROCEDURE Cap*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    IF ('a' <= s[i]) & (s[i] <= 'z') THEN s[i] := CAP(s[i]) END;
    INC(i)
  END
END Cap;

PROCEDURE Match*(IN string, pattern: ARRAY OF CHAR): BOOLEAN;

  PROCEDURE M (IN name, mask: ARRAY OF CHAR; n, m: INTEGER): BOOLEAN;
  BEGIN
    WHILE (n >= 0) & (m >= 0) & (mask[m] # '*') DO
      IF name[n] # mask[m] THEN RETURN FALSE END;
      DEC(n); DEC(m)
    END;
    (* ----- name empty | mask empty | mask ends with '*' *)
    IF m < 0 THEN RETURN n < 0 END;
    (* ----- name empty | mask ends with '*' *)
    WHILE (m >= 0) & (mask[m] = '*') DO DEC(m) END;
    IF m < 0 THEN RETURN TRUE END;
    (* ----- name empty | mask still to be matched *)
    WHILE n >= 0 DO
      IF M(name, mask, n, m) THEN RETURN TRUE END;
      DEC(n)
    END;
    RETURN FALSE
  END M;

BEGIN
  RETURN M(string, pattern, Length(string) - 1, Length(pattern) - 1)
END Match;

END Strings.
