unit Atom.Convert;

interface

uses
  Windows, Variants, AnsiStrings, Classes, SysUtils, StrUtils, DateUtils, Math;

  // Rotinas de conversão de dados
  function IntToCard(I : integer): Cardinal;                                    // Converte Inteiro em Card.
  function IntToBool(I : integer): Boolean;                                     // Converte Inteiro em Boolean.
  function BoolToInt(B : Boolean): Integer;                                     // Converte Boolean em Inteiro.
  function StrToBool(S : String): Boolean;                                      // Converte String em Boolean.
  function BoolToStr(B : Boolean): String;                                      // Converte Boolean em String.
  function StrToPAnsiChar(const s: String): PAnsiChar;                          // Converte String em PAnsiChar.
  function StrToPWideChar(const s: String): PWideChar;                          // Converte String em PWideChar.

implementation

function IntToCard(I : integer): Cardinal;
begin
  Result := I - Low(Integer)
end;

function IntToBool(I : integer): Boolean;
begin
  if I = 0 then
    Result := False
  else
    Result := True;
end;

function BoolToInt(B : Boolean): Integer;
begin
  if B = False then
    Result := 0
  else
    Result := 1;
end;

function StrToBool(S : String): Boolean;
begin
  if (s = 'S') or (s = 'SIM') then
    Result := True
  else
    Result := False;
end;

function BoolToStr(B : Boolean): String;
begin
  if b then
    Result := 'S'
  else
    Result := 'N';
end;

function StrToPWideChar(const s: String): PWideChar;
begin
  Result := PWideChar(WideString(s));
end;

function StrToPAnsiChar(const s: String): PAnsiChar;
begin
  Result := PAnsiChar(s);
end;

end.
