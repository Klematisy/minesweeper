program minesweeper;
uses
    Unix,
    keyboard,
    SysUtils;

const width = 8;
const height = 8;
const countOfBombs = 10;

type
    Point = record
    x, y: integer;
end;

var
    gameIsRunning:  boolean;
    gameStatus:     boolean;
    countOfFlags:   integer;
    gameFieldInNum: array [1..(width * height + 1)] of integer;
    gameField:      array [1..(width * height + 1)] of string;
    Bombs:          set of 1..(width * height + 1);
    pointer: Point;
 

procedure recursion(i, j: integer);
var m, n: integer;
begin
    gameField[i + j * width] := '   ';
    For m:=-1 to 1 do begin
        For n:=-1 to 1 do begin
            if not((m = 0) and (n = 0)) and
            (1 <= (i + m)) and ((i + m) <=  width) and 
            (0 <= (j + n)) and ((j + n) <  height) then
            begin
                if (gameFieldInNum[i + m + (j + n) * width] = 0) and not(gameField[i + m + (j + n) * width] = '   ') then 
                    recursion(i + m, j + n)
                else if (gameFieldInNum[i + m + (j + n) * width] <> 0) and (gameField[i + m + (j + n) * width] = ' . ') then
                begin
                    gameField[i + m + (j + n) * width] := ' ' + IntToStr(gameFieldInNum[i + m + (j + n) * width]) + ' ';
                end;
            end;
        end;
    end;
end;

procedure ShowBombs();
var i: integer;
begin
    For i:=1 to width * height do begin
        if (gameFieldInNum[i] = 9) then
            gameField[i] := ' * ';
    end;
end;

procedure EndGameCheck();
var i: integer;
begin
    For i:=1 to width * height do begin
        if( (gameField[i] = ' . ') or (gameField[i] = ' X ')) and (gameFieldInNum[i] <> 9) then begin
            Exit;
        end;
    end;
    gameIsRunning := false;
    gameStatus := true;
    ShowBombs();
end;

procedure PointerTransition(key: string);
begin
    if (key = 'Up') and (pointer.y > 0) then
        Dec(pointer.y);

    if (key = 'Down') and (pointer.y < height - 1) then
        Inc(pointer.y);

    if (key = 'Right') and (pointer.x < width) then
        Inc(pointer.x);

    if (key = 'Left') and (pointer.x > 1) then
        Dec(pointer.x);
end;

procedure PutAFlag();
begin
    if (gameField[pointer.x + pointer.y * width]  = ' . ') then begin
        gameField[pointer.x + pointer.y * width] := ' X ';
        Inc(countOfFlags);
    end else if (gameField[pointer.x + pointer.y * width]  = ' X ') then begin
        gameField[pointer.x + pointer.y * width] := ' . ';
        Dec(countOfFlags);
    end;
end;

procedure PickTheCell();
begin
    if (gameFieldInNum[pointer.x + pointer.y * width] = 0) then begin
        recursion(pointer.x, pointer.y);
    end else begin
        if (gameFieldInNum[pointer.x + pointer.y * width] = 9) then begin
            gameIsRunning := false;
            gameStatus := false;
            ShowBombs();
        end else
            gameField[pointer.x + pointer.y * width] := ' ' + IntToStr(gameFieldInNum[pointer.x + pointer.y * width]) + ' ';
    end;
    EndGameCheck();
end;

procedure Update();
var K: TKeyEvent;
    key: string;
begin
    K := GetKeyEvent;
    K := TranslateKeyEvent(K);
    key := KeyEventToString(K);

    if (key = 'x') or (key = 'X') then begin
        PutAFlag();
    end;

    if (key = 'z') or (key = 'Z') then begin
        PickTheCell();
    end;

    PointerTransition(key);

    if (key = 'q') then 
        gameIsRunning := false;
end;

procedure Draw();
var gameFieldCopy: array [1..(width * height + 1)] of string;
var i: integer;
begin
    For i:=1 to width * height do begin
        gameFieldCopy[i] := gameField[i];
    end;

    gameFieldCopy[pointer.x + pointer.y * width] := '[' + gameField[pointer.x + pointer.y * width][2] + ']';

    fpSystem('clear');
    For i:=1 to width * height do begin
        Write(gameFieldCopy[i]);
        if ((i mod height) = 0) then
            Writeln('');
    end;
    Writeln('');

    Writeln('Bombs: ', countOfFlags, '/', countOfBombs);
end;

procedure FillBombs();
var i, num: integer;
begin
    i := 0;
    while (i <> countOfBombs) do begin
        i := 0;
        Bombs := Bombs + [Random(width * height) + 1];
        for num := 1 to width * height do begin
            if num in Bombs then begin
                Inc(i);
            end;
        end;
    end;

    For i:=1 to width * height do begin
        if i in Bombs then
            gameFieldInNum[i] := 9
        else
            gameFieldInNum[i] := 0;
    end;
end;

procedure FillTheNumField();
var neighbours, i, j, m, n: integer;
begin
    For i:=0 to (height - 1) do begin
        For j:=1 to width do begin
            neighbours := 0;
            For m:=-1 to 1 do begin
                For n:=-1 to 1 do begin
                    if not((m = 0) and (n = 0)) and 
                    (1 <= (j + m)) and ((j + m) <= width) and 
                    (0 <= (i + n)) and ((i + n) <= height) then
                    begin
                        if (gameFieldInNum[j + m + (i + n) * width] = 9) then
                            Inc(neighbours);
                    end;
                end;
            end;
            if not(gameFieldInNum[j + i * width] = 9) then
                gameFieldInNum[j + i * width] := neighbours;
            
            Write(gameFieldInNum[j + i * width], ' ');
        end;
        Writeln('');
    end;
end;

procedure init();
var i: integer;
begin
    InitKeyBoard;
    Randomize;

    gameIsRunning := true;
    gameStatus := false;

    For i:=1 to width * height do begin
        gameField[i] := ' . ';
    end;

    FillBombs();
    FillTheNumField();

    pointer.x := 1;
    pointer.y := 0;

    countOfFlags := 0;
end;

procedure deinit();
begin
    DoneKeyBoard;
end;

begin
    init();

    Draw();
    while(gameIsRunning) do begin
        Update();
        Draw();
    end;

    if (gameStatus) then
        Write('You win!')
    else
        Write('You lose!');

    deinit();
end.