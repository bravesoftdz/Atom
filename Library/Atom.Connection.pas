unit Atom.Connection;

interface

uses
  Windows, Variants, Classes, SysUtils, Uni, UniProvider, SQLiteUniProvider,
  Atom.Basic, Atom.Form, Atom.Convert, Atom.SQLite3, Atom.SQLiteTable3;

type
  TDBConfig = class
  private
    FDBProxyHost: String;
    FDBPort: String;
    FDBProxyUser: String;
    FDBDataBase: String;
    FSystemConf: Boolean;
    FDBHost: String;
    FSystemConectado: Boolean;
    FDBMasterPass: String;
    FSystemAuth: Boolean;
    FDBMasterUser: String;
    FDBProxyPort: String;
    FDBProxyPass: String;
    FDBLogPath: String;
    FDBLogEnable: Boolean;
    procedure SetDBDataBase(const Value: String);
    procedure SetDBHost(const Value: String);
    procedure SetDBMasterPass(const Value: String);
    procedure SetDBMasterUser(const Value: String);
    procedure SetDBPort(const Value: String);
    procedure SetDBProxyHost(const Value: String);
    procedure SetDBProxyPass(const Value: String);
    procedure SetDBProxyPort(const Value: String);
    procedure SetDBProxyUser(const Value: String);
    procedure SetSystemAuth(const Value: Boolean);
    procedure SetSystemConectado(const Value: Boolean);
    procedure SetSystemConf(const Value: Boolean);
    procedure SetDBLogEnable(const Value: Boolean);
    procedure SetDBLogPath(const Value: String);
  public
    // Configurações de Acesso ao banco.
    property DBHost: String read FDBHost write SetDBHost;
    property DBPort: String read FDBPort write SetDBPort;
    property DBDataBase: String read FDBDataBase write SetDBDataBase;
    property DBMasterUser: String read FDBMasterUser write SetDBMasterUser;
    property DBMasterPass: String read FDBMasterPass write SetDBMasterPass;
    property DBProxyHost: String read FDBProxyHost write SetDBProxyHost;
    property DBProxyPort: String read FDBProxyPort write SetDBProxyPort;
    property DBProxyUser: String read FDBProxyUser write SetDBProxyUser;
    property DBProxyPass: String read FDBProxyPass write SetDBProxyPass;
    // Configurações do Terminal
    property DBLogEnable: Boolean read FDBLogEnable write SetDBLogEnable;
    property DBLogPath: String read FDBLogPath write SetDBLogPath;
    // Variaveis de Ambiente
    property SystemAuth: Boolean read FSystemAuth write SetSystemAuth;
    property SystemConectado: Boolean read FSystemConectado write SetSystemConectado;
    property SystemConf: Boolean read FSystemConf write SetSystemConf;
    // Rotinas
    function CheckConfig(var Connection: TUniConnection; Path: String): Boolean;
    function CheckDBConnConfig(var Connection: TUniConnection; Query: TUniQuery): Boolean;
    function OpenGetConnection(Connection: TUniConnection): Boolean;
    function DBSaveConfig(Query: TUniQuery): Boolean;
    procedure ImportConfig(SDBHost, SDBPort, SDBDataBase, SDBMasterUser, SDBMasterPass, SDBProxyHost, SDBProxyPort, SDBProxyUser, SDBProxyPass, SDBLogPath: String; SDBLogEnable: Boolean);
    procedure DBGeraConfig(Path: String);
    procedure CarregarConfigServer(Config: TDBConfig);
    procedure OpenConnection(Connection: TUniConnection);
    procedure CloseConnection(Connection: TUniConnection);
  end;

implementation

{$REGION 'TDBConfig'}
procedure TDBConfig.CarregarConfigServer(Config: TDBConfig);
begin
  try
    begin
      DBHost := Config.DBHost;
      DBPort := Config.DBPort;
      DBDataBase := Config.DBDataBase;
      DBMasterUser := Config.DBMasterUser;
      DBMasterPass := Config.DBMasterPass;
      DBProxyHost := Config.DBHost;
      DBProxyPort := Config.DBProxyPort;
      DBProxyUser := Config.DBProxyUser;
      DBProxyPass := Config.DBProxyPass;
      DBLogEnable := Config.DBLogEnable;
      DBLogPath := Config.DBLogPath;
    end;
  except
    Aviso('ERRO','Erro ao configurar','Não foi possivel carregar as configurações do Sistema.'+#13+'Por favor entre em contato com o Suporte.');
  end;
end;

function TDBConfig.CheckConfig(var Connection: TUniConnection; Path: String): Boolean;
var
  dbConfig: String;
begin
  dbConfig := Path + '\config\dbconfig.sqlite';
  if not FileExists(dbConfig) then
  begin
    try
      DBGeraConfig(Path);
    except
      Result:= False;
      Aviso('ERRO','Erro ao gerar arquivo','Não foi possivel gerar o registro de configuração.'+#13+'Por favor entre em contato com o Suporte.');
      Exit;
    end;
  end;
  Connection.Database := dbConfig;
  try
    try
      Connection.Connect;
    finally
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TDBConfig.CheckDBConnConfig(var Connection: TUniConnection;
  Query: TUniQuery): Boolean;
var
  ls_SQL: String;
begin
  ls_SQL := Query.SQL.Text;
  if Connection.Connected = True then
    begin
      Query.Open;
      if Query.RecordCount = 0 then
        begin
          Result := False;
        end
      else
        begin
          Query.Close;
          Query.SQL.Text := 'SELECT * FROM servidores WHERE defaultconn = 1';
          Query.Open;
          if Query.RecordCount > 0 then
          begin
            // Passa os parametros da conexão!
            DBHost := Query.FieldByName('DBHost').AsString;
            DBPort := Query.FieldByName('DBPort').AsString;
            DBDataBase := Query.FieldByName('DBDataBase').AsString;
            DBMasterUser := Query.FieldByName('DBMasterUser').AsString;
            DBMasterPass := Query.FieldByName('DBMasterPass').AsString;
            DBProxyHost := Query.FieldByName('DBProxyHost').AsString;
            DBProxyPort := Query.FieldByName('DBProxyPort').AsString;
            DBProxyUser := Query.FieldByName('DBProxyUser').AsString;
            DBProxyPass := Query.FieldByName('DBProxyPass').AsString;
            DBLogPath := Query.FieldByName('DBLogPath').AsString;
            DBLogEnable := IntToBool(Query.FieldByName('DBLogEnable').AsInteger);
            Result := True;
          end
          else
          begin
            Result := False;
          end;
          Query.Close;
        end;
    end
  else
    begin
      Result := False;
    end;
  Query.SQL.Text := ls_SQL;
end;

procedure TDBConfig.CloseConnection(Connection: TUniConnection);
begin
  Connection.Close;
end;

procedure TDBConfig.DBGeraConfig(Path: String);
// Gera o banco para configurações do sistema no SQLite
var
  slDBpath: string;
  sldb: TSQLiteDatabase;
  sSQL: AnsiString;
begin
  slDBPath := Path + '\config\dbconfig.sqlite';
  sldb := TSQLiteDatabase.Create(slDBPath);
  try
    sldb.BeginTransaction;

    if sldb.TableExists('servidores') then
    begin
      sSQL := 'DROP TABLE servidores';
      sldb.execsql(sSQL);
    end;

    // Cria a tabela de registro
    sSQL:= 'CREATE TABLE servidores ( '+
	         'codigo INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '+
	         'nome TEXT NOT NULL DEFAULT ''PADRAO'', '+
	         'dbhost TEXT NOT NULL DEFAULT ''127.0.0.1'', '+
	         'dbport INTEGER NOT NULL DEFAULT ''5432'', '+
	         'dbdataBase TEXT NOT NULL DEFAULT ''narseo'', '+
	         'dbmasterUser TEXT NOT NULL DEFAULT ''postgres'', '+
	         'dbmasterPass TEXT NOT NULL DEFAULT ''postgres'', '+
	         'dbproxyHost TEXT, '+
	         'dbproxyPort TEXT, '+
	         'dbproxyUser TEXT, '+
	         'dbproxyPass TEXT, '+
	         'dblogPath TEXT, '+
           'dblogEnable INTEGER DEFAULT 0, '+
	         'defaultconn INTEGER NOT NULL DEFAULT 0 ' +
	         ');';
    sldb.execsql(sSQL);
    sldb.Commit;

  finally
    sldb.Free;
  end;
end;

function TDBConfig.DBSaveConfig(Query: TUniQuery): Boolean;
begin
  if not Query.Active then
    Query.Open;
  try
    try
      Query.Edit;
      Query.FieldByName('dbhost').AsString := DBHost;
      Query.FieldByName('dbport').AsString := DBPort;
      Query.FieldByName('dbdataBase').AsString := DBDataBase;
      Query.FieldByName('dbmasterUser').AsString := DBMasterUser;
      Query.FieldByName('dbmasterPass').AsString := DBMasterPass;
      Query.FieldByName('dbproxyHost').AsString := DBProxyHost;
      Query.FieldByName('dbproxyPort').AsString := DBProxyPort;
      Query.FieldByName('dbproxyUser').AsString := DBProxyUser;
      Query.FieldByName('dbproxyPass').AsString := DBProxyPass;
      Query.FieldByName('dblogEnable').AsString := IntToStr(BoolToInt(DBLogEnable));
      Query.FieldByName('dblogPath').AsString := DBLogPath;
      Query.FieldByName('defaultconn').AsInteger := 1;
      Query.Post;
    finally
      Result := True;
    end;
  except
    Result := False;
  end;
end;

procedure TDBConfig.ImportConfig(SDBHost, SDBPort, SDBDataBase, SDBMasterUser, SDBMasterPass, SDBProxyHost, SDBProxyPort, SDBProxyUser, SDBProxyPass, SDBLogPath: String; SDBLogEnable: Boolean);
begin
  DBHost := SDBHost;
  DBPort := SDBPort;
  DBDataBase := SDBDataBase;
  DBMasterUser := SDBMasterUser;
  DBMasterPass := SDBMasterPass;
  DBProxyHost := SDBProxyHost;
  DBProxyPort := SDBProxyPort;
  DBProxyUser := SDBProxyUser;
  DBProxyPass := SDBProxyPass;
  DBLogEnable := SDBLogEnable;
  DBLogPath := SDBLogPath;
end;

procedure TDBConfig.OpenConnection(Connection: TUniConnection);
begin
  if Connection is TUniConnection then
    begin
      try
        with TUniConnection(Connection) do
          begin
            Server    := DBHost;
            Port      := StrToInt(DBPort);
            Username  := DBMasterUser;
            Password  := DBMasterPass;
            Database  := DBDataBase;
          end;
        TUniConnection(Connection).Open;
        SystemConf := True;
      except
        Aviso('ERRO','Falha na conexão','Ocorreu uma falha na conexão com o servidor.'+#13+'Verifique a configuração, se persistir entre em contato com o Suporte !');
        SystemConf := False;
      end;
    end;
end;

function TDBConfig.OpenGetConnection(Connection: TUniConnection): Boolean;
begin
  OpenConnection(Connection);
  Result := SystemConf;
end;

{$REGION 'SETS'}
procedure TDBConfig.SetDBDataBase(const Value: String);
begin
  FDBDataBase := Value;
end;

procedure TDBConfig.SetDBHost(const Value: String);
begin
  FDBHost := Value;
end;

procedure TDBConfig.SetDBLogEnable(const Value: Boolean);
begin
  FDBLogEnable := Value;
end;

procedure TDBConfig.SetDBLogPath(const Value: String);
begin
  FDBLogPath := Value;
end;

procedure TDBConfig.SetDBMasterPass(const Value: String);
begin
  FDBMasterPass := Value;
end;

procedure TDBConfig.SetDBMasterUser(const Value: String);
begin
  FDBMasterUser := Value;
end;

procedure TDBConfig.SetDBPort(const Value: String);
begin
  FDBPort := Value;
end;

procedure TDBConfig.SetDBProxyHost(const Value: String);
begin
  FDBProxyHost := Value;
end;

procedure TDBConfig.SetDBProxyPass(const Value: String);
begin
  FDBProxyPass := Value;
end;

procedure TDBConfig.SetDBProxyPort(const Value: String);
begin
  FDBProxyPort := Value;
end;

procedure TDBConfig.SetDBProxyUser(const Value: String);
begin
  FDBProxyUser := Value;
end;

procedure TDBConfig.SetSystemAuth(const Value: Boolean);
begin
  FSystemAuth := Value;
end;

procedure TDBConfig.SetSystemConectado(const Value: Boolean);
begin
  FSystemConectado := Value;
end;

procedure TDBConfig.SetSystemConf(const Value: Boolean);
begin
  FSystemConf := Value;
end;
{$ENDREGION}

{$ENDREGION}
end.
