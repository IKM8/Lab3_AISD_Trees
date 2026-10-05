PROGRAM Lab3;
{
  PascalABC.NET 4.0
  Группа ПС-21. Глушков Никита
  3 Лабораторная работа
  Вариант 15.
  В некотором институте информация об имеющихся компьютерах задана деревом.
  Сыновьям корневой вершины соответствуют факультеты, факультеты в свою
  очередь делятся на кафедры, кафедры могут иметь в своем составе лаборатории.
  Компьютеры могут быть установлены в общих факультетских классах, на кафедрах,
  в лабораториях и идентифицируются уникальными номерами.
  Требуется найти:
  1) факультеты с минимальным и максимальным числом компьютеров;
  2) кафедры с минимальным и максимальным числом компьютеров (9).
  Источники:
}

TYPE
  PNode = ^Node;
  Node = RECORD
           Name: STRING;     { название узла }
           Comp: INTEGER;    { число компьютеров в этом узле }
           Child: PNode;     { первый сын }
           Next: PNode;      { следующий брат }
         END;

VAR
  Root: PNode;
  FileName: STRING;
  Ans: CHAR;
  Again: BOOLEAN;

{ убирает пробелы в конце строки }
FUNCTION TrimRight(Str: STRING): STRING;
VAR
  I, Last: INTEGER;
  Res: STRING;
BEGIN
  Last := 0;
  FOR I := 1 TO LENGTH(Str)
  DO
    IF Str[I] <> ' '
    THEN
      Last := I;
  Res := '';
  FOR I := 1 TO Last
  DO
    Res := Res + Str[I];
  TrimRight := Res;
END;

{ добавляет узел последним сыном }
PROCEDURE AddChild(Parent, NewNode: PNode);
VAR
  Q: PNode;
BEGIN
  IF Parent^.Child = NIL
  THEN
    Parent^.Child := NewNode
  ELSE
    BEGIN
      Q := Parent^.Child;
      WHILE Q^.Next <> NIL
      DO
        Q := Q^.Next;
      Q^.Next := NewNode;
    END;
END;

{ читает дерево из файла (уровень задается числом точек в начале строки) }
PROCEDURE LoadTree(FileName: STRING);
VAR
  F: TEXT;
  S: STRING;
  Level, K, Len, Num, I: INTEGER;
  Name: STRING;
  NewNode: PNode;
  Stack: ARRAY[0..20] OF PNode;
BEGIN
  ASSIGN(F, FileName);
  TRY
    RESET(F);
  EXCEPT
    WRITELN('Не удалось открыть файл!');
    HALT(1);
  END;

  FOR I := 0 TO 20
  DO
    Stack[I] := NIL;
  Root := NIL;

  WHILE NOT EOF(F)
  DO
    BEGIN
      READLN(F, S);
      Len := LENGTH(S);
      IF Len > 0
      THEN
        BEGIN
          { уровень = количество точек (не больше 20) }
          Level := 0;
          WHILE (Level < Len) AND (Level < 20) AND (S[Level + 1] = '.')
          DO
            Level := Level + 1;

          { имя узла - до символа ':' }
          Name := '';
          K := Level + 1;
          WHILE (K <= Len) AND (S[K] <> ':')
          DO
            BEGIN
              Name := Name + S[K];
              K := K + 1;
            END;
          Name := TrimRight(Name);

          NEW(NewNode);
          NewNode^.Name := Name;
          NewNode^.Comp := 0;
          NewNode^.Child := NIL;
          NewNode^.Next := NIL;

          { номера компьютеров после ':' }
          IF K <= Len
          THEN
            BEGIN
              K := K + 1;
              WHILE K <= Len
              DO
                BEGIN
                  IF (S[K] >= '0') AND (S[K] <= '9')
                  THEN
                    BEGIN
                      Num := 0;
                      WHILE (K <= Len) AND (S[K] >= '0') AND (S[K] <= '9')
                      DO
                        BEGIN
                          Num := Num * 10 + (ORD(S[K]) - ORD('0'));
                          K := K + 1;
                        END;
                      NewNode^.Comp := NewNode^.Comp + 1;
                    END
                  ELSE
                    K := K + 1;
                END;
            END;

          IF Level = 0
          THEN
            BEGIN
              IF Root = NIL
              THEN
                Root := NewNode
              ELSE
                AddChild(Root, NewNode);
              Stack[0] := NewNode;
            END
          ELSE
            IF Stack[Level - 1] <> NIL
            THEN
              BEGIN
                AddChild(Stack[Level - 1], NewNode);
                Stack[Level] := NewNode;
              END
            ELSE
              { нет родителя на предыдущем уровне - строка некорректна, пропускаем }
              DISPOSE(NewNode);
        END;
    END;
  CLOSE(F);
END;

{ сумма компьютеров в поддереве }
FUNCTION SumComp(P: PNode): INTEGER;
VAR
  Q: PNode;
  T: INTEGER;
BEGIN
  T := P^.Comp;
  Q := P^.Child;
  WHILE Q <> NIL
  DO
    BEGIN
      T := T + SumComp(Q);
      Q := Q^.Next;
    END;
  SumComp := T;
END;

{ показ дерева на экране }
PROCEDURE ShowTree(P: PNode; Level: INTEGER);
VAR
  Q: PNode;
  I: INTEGER;
BEGIN
  FOR I := 1 TO Level
  DO
    WRITE('  ');
  WRITELN(P^.Name, ' [компьютеров: ', SumComp(P), ']');
  Q := P^.Child;
  WHILE Q <> NIL
  DO
    BEGIN
      ShowTree(Q, Level + 1);
      Q := Q^.Next;
    END;
END;

{ факультеты с мин/макс числом компьютеров }
PROCEDURE FacMinMax;
VAR
  Fac: PNode;
  V: INTEGER;
  First: BOOLEAN;
  MinV, MaxV: INTEGER;
  MinN, MaxN: STRING;
BEGIN
  MinV := 0;
  MaxV := 0;
  MinN := '';
  MaxN := '';
  First := TRUE;
  Fac := Root^.Child;

  WHILE Fac <> NIL
  DO
    BEGIN
      V := SumComp(Fac);
      IF First OR (V < MinV)
      THEN
        BEGIN
          MinV := V;
          MinN := Fac^.Name;
        END;
      IF First OR (V > MaxV)
      THEN
        BEGIN
          MaxV := V;
          MaxN := Fac^.Name;
        END;
      First := FALSE;
      Fac := Fac^.Next;
    END;

  IF First
  THEN
    WRITELN('Факультетов нет.')
  ELSE
    BEGIN
      WRITELN('Факультет с минимальным числом компьютеров: ', MinN, ' (', MinV, ')');
      WRITELN('Факультет с максимальным числом компьютеров: ', MaxN, ' (', MaxV, ')');
    END;
END;

{ кафедры с мин/макс числом компьютеров }
PROCEDURE DepMinMax;
VAR
  Fac, Dep: PNode;
  V: INTEGER;
  First: BOOLEAN;
  MinV, MaxV: INTEGER;
  MinN, MaxN: STRING;
BEGIN
  MinV := 0;
  MaxV := 0;
  MinN := '';
  MaxN := '';
  First := TRUE;
  Fac := Root^.Child;

  WHILE Fac <> NIL
  DO
    BEGIN
      Dep := Fac^.Child;
      WHILE Dep <> NIL
      DO
        BEGIN
          V := SumComp(Dep);
          IF First OR (V < MinV)
          THEN
            BEGIN
              MinV := V;
              MinN := Dep^.Name;
            END;
          IF First OR (V > MaxV)
          THEN
            BEGIN
              MaxV := V;
              MaxN := Dep^.Name;
            END;
          First := FALSE;
          Dep := Dep^.Next;
        END;
      Fac := Fac^.Next;
    END;

  IF First
  THEN
    WRITELN('Кафедр нет.')
  ELSE
    BEGIN
      WRITELN('Кафедра с минимальным числом компьютеров: ', MinN, ' (', MinV, ')');
      WRITELN('Кафедра с максимальным числом компьютеров: ', MaxN, ' (', MaxV, ')');
    END;
END;

BEGIN
  WRITE('Введите имя входного файла: ');
  READLN(FileName);
  LoadTree(FileName);

  Again := TRUE;
  WHILE Again
  DO
    BEGIN
      WRITELN;
      WRITELN('1 - показать дерево');
      WRITELN('2 - факультеты с мин/макс числом компьютеров');
      WRITELN('3 - кафедры с мин/макс числом компьютеров');
      WRITELN('4 - выход');
      WRITE('Ваш выбор: ');
      READLN(Ans);

      IF Ans = '1'
      THEN
        BEGIN
          IF Root = NIL
          THEN
            WRITELN('Дерево пустое или не было загружено.')
          ELSE
            ShowTree(Root, 0);
        END
      ELSE
        IF Ans = '2'
        THEN
          BEGIN
            IF Root = NIL
            THEN
              WRITELN('Дерево пустое или не было загружено.')
            ELSE
              FacMinMax;
          END
        ELSE
          IF Ans = '3'
          THEN
            BEGIN
              IF Root = NIL
              THEN
                WRITELN('Дерево пустое или не было загружено.')
              ELSE
                DepMinMax;
            END
          ELSE
            IF Ans = '4'
            THEN
              Again := FALSE
            ELSE
              WRITELN('Неверный выбор.');
    END;
END.
