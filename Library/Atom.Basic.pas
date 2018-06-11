unit Atom.Basic;

interface

uses
  Windows, Variants, SysUtils, Winsock, Forms;

type
  // Define as formas que o form podera ser aberto
  TModoExibicao = (tmConsulta, tmInsert, tmEdit, tmExport, tmNone = 10);

  // Utilizado para identificar como os formularios serão utilizados
  TFormMode = class
  private
    FID: Integer;
    FModo: TModoExibicao;
    procedure SetID(const Value: Integer);
    procedure SetModo(const Value: TModoExibicao);
  public
    property Modo: TModoExibicao read FModo write SetModo;                      // Identifica o modo do formulario.
    property ID: Integer read FID write SetID;                                  // Identifica o indece desejado quando existir operação.
  end;

  TFormConsulta = class
  private
    FeChave: Integer;
    FeValido: Boolean;
    FeDescricao: String;
    FeConsulta: Boolean;
    procedure SeteChave(const Value: Integer);
    procedure SeteConsulta(const Value: Boolean);
    procedure SeteDescricao(const Value: String);
    procedure SeteValido(const Value: Boolean);
  public
    property eConsulta: Boolean read FeConsulta write SeteConsulta;
    property eDescricao: String read FeDescricao write SeteDescricao;
    property eChave: Integer read FeChave write SeteChave;
    property eValido: Boolean read FeValido write SeteValido;
  end;

  THost = class
  private
    FIP: String;
    FNome: String;
    FUserNerwork: String;
    procedure SetIP(const Value: String);
    procedure SetNome(const Value: String);
    procedure SetUserNerwork(const Value: String);
    function NetHostName: string;
    function NetUserName: string;
    function NetHostIP: string;
  public
    property Nome: String read FNome write SetNome;
    property UserNerwork: String read FUserNerwork write SetUserNerwork;
    property IP: String read FIP write SetIP;
    procedure GetHostData;
  end;

  TSettings = class
  private
    FSystemPrinter: String;
    FSystemHost: THost;
    FSystemPath: String;
    procedure SetSystemHost(const Value: THost);
    procedure SetSystemPath(const Value: String);
    procedure SetSystemPrinter(const Value: String);
  public
    property SystemHost: THost read FSystemHost write SetSystemHost;
    property SystemPath: String read FSystemPath write SetSystemPath;
    property SystemPrinter: String read FSystemPrinter write SetSystemPrinter;
    procedure getSystemSettings;
  end;

implementation

{$REGION 'TFormMode'}
procedure TFormMode.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TFormMode.SetModo(const Value: TModoExibicao);
begin
  FModo := Value;
end;
{$ENDREGION}

{$REGION 'TConsulta'}
procedure TFormConsulta.SeteChave(const Value: Integer);
begin
  FeChave := Value;
end;

procedure TFormConsulta.SeteConsulta(const Value: Boolean);
begin
  FeConsulta := Value;
end;

procedure TFormConsulta.SeteDescricao(const Value: String);
begin
  FeDescricao := Value;
end;

procedure TFormConsulta.SeteValido(const Value: Boolean);
begin
  FeValido := Value;
end;
{$ENDREGION}

{$REGION 'THost'}
procedure THost.GetHostData;
begin
  FNome := NetHostName;
  FUserNerwork := NetUserName;
  FIP := NetHostIP;
end;

function THost.NetHostIP: string;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Name: String;
begin
  WSAStartup(2, WSAData);
  SetLength(Name, 255);
  Gethostname(PAnsiChar(Name), 255);
  SetLength(Name, StrLen(PChar(Name)));
  HostEnt := gethostbyname(PAnsiChar(Name));
  with HostEnt^ do
  begin
    Result := Format('%d.%d.%d.%d',[Byte(h_addr^[0]),Byte(h_addr^[1]),Byte(h_addr^[2]),Byte(h_addr^[3])]);
  end;
  WSACleanup;
end;

function THost.NetHostName: string;
// Retorna o nome do computador
var
  lpBuffer : PChar;
  nSize    : DWord;
const Buff_Size = MAX_COMPUTERNAME_LENGTH + 1;
begin
  try
    nSize    := Buff_Size;
    lpBuffer := StrAlloc(Buff_Size);
    GetComputerName(lpBuffer,nSize);
    Result   := String(lpBuffer);
    StrDispose(lpBuffer);
  except
    Result := '';
  end;
end;

function THost.NetUserName: string;
var
  lpBuffer : PChar;
  nSize : DWord;
const
  Buff_Size = 100;
begin
  nSize := Buff_Size;
  lpBuffer := StrAlloc(Buff_Size);
  GetUserName(lpBuffer,nSize);
  Result := string(lpBuffer);
  StrDispose(lpBuffer);
end;

procedure THost.SetIP(const Value: String);
begin
  FIP := Value;
end;

procedure THost.SetNome(const Value: String);
begin
  FNome := Value;
end;
procedure THost.SetUserNerwork(const Value: String);
begin
  FUserNerwork := Value;
end;

{$ENDREGION}

{$REGION 'TSettings'}
procedure TSettings.getSystemSettings;
begin
  // SystemHost.GetHostData;
  SystemPath := ExtractFileDir(Application.ExeName);
end;

procedure TSettings.SetSystemHost(const Value: THost);
begin
  FSystemHost := Value;
end;

procedure TSettings.SetSystemPath(const Value: String);
begin
  FSystemPath := Value;
end;

procedure TSettings.SetSystemPrinter(const Value: String);
begin
  FSystemPrinter := Value;
end;
{$ENDREGION}

end.
