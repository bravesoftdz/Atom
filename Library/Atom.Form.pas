unit Atom.Form;

interface

uses
  Windows, Variants, Forms, Classes, SysUtils, StrUtils, AnsiStrings, DateUtils,
  Atom.Basic, Atom.Convert;

  function Pergunta(vType,vTitulo,vMensagem,vOpcao:String):Integer;             // Cria janela de questionamento (Application.Messagebox) aguardando retorno.
  procedure Aviso(vType,vTitulo,vMensagem:String);                              // Cria janela de aviso (Application.Messagebox).
  procedure CriaDM(InstanceClass: TComponentClass; var Reference);              // Abre formularios > Substitui o Application.CreateForm
  procedure AbreFormulario(InstanceClass: TComponentClass; var Reference);      // Abre formularios > Substitui o Application.CreateForm
  procedure CriaFormulario(InstanceClass: TComponentClass; TID: Integer; TModo: TModoExibicao; var Reference);

implementation

function Pergunta(vType,vTitulo,vMensagem,vOpcao:String):Integer;
// Cria janela de questionamento (Application.Messagebox) aguardando retorno.
var
  msgIC, msgBT: Integer;
begin

  msgIC := MB_ICONINFORMATION;

  case AnsiIndexStr(UpperCase(vOpcao), ['SN','SNC']) of
    0:msgBT := MB_YESNO;
    1:msgBT := MB_YESNOCANCEL
  else
    msgBT := MB_OK;
  end;

  case AnsiIndexStr(UpperCase(vType), ['ERRO','INFO','ALER','STOP','HAND','WHAT','STER','WARN']) of
    0:msgIC := MB_ICONERROR;
    1:msgIC := MB_ICONINFORMATION;
    2:msgIC := MB_ICONEXCLAMATION;
    3:msgIC := MB_ICONSTOP;
    4:msgIC := MB_ICONHAND;
    5:msgIC := MB_ICONQUESTION;
    6:msgIC := MB_ICONASTERISK;
    7:msgIC := MB_ICONWARNING;
  end;

  Result := Application.MessageBox(StrToPWideChar(vMensagem),StrToPWideChar(vTitulo),msgIC + msgBT);

end;

procedure Aviso(vType,vTitulo,vMensagem:String);
// Cria janela de aviso (Application.Messagebox).
var msgIC: Integer;
begin

  msgIC := MB_ICONINFORMATION;

  case AnsiIndexStr(UpperCase(vType), ['ERRO','INFO','ALER','STOP','HAND','WHAT','STER','WARN']) of
    0:msgIC := MB_ICONERROR;
    1:msgIC := MB_ICONINFORMATION;
    2:msgIC := MB_ICONEXCLAMATION;
    3:msgIC := MB_ICONSTOP;
    4:msgIC := MB_ICONHAND;
    5:msgIC := MB_ICONQUESTION;
    6:msgIC := MB_ICONASTERISK;
    7:msgIC := MB_ICONWARNING;
  end;

  Application.MessageBox(StrToPWideChar(vMensagem),StrToPWideChar(vTitulo), msgIC + MB_OK);

end;

procedure CriaDM(InstanceClass: TComponentClass; var Reference);
// Abre formularios > Substitui o Application.CreateForm
begin
  // Verifica se o Formulario ja foi Instanciado
  try
    Application.CreateForm(InstanceClass, Reference);
  except
    Aviso('ERRO','Informação','Não foi possivel carregar o container. Entre em contato com o suporte.');
  end;
end;

procedure AbreFormulario(InstanceClass: TComponentClass; var Reference);
// Abre formularios > Substitui o Application.CreateForm
begin
  // Verifica se o Formulario ja foi Instanciado
  try
    Application.CreateForm(InstanceClass, Reference);
    TForm(Reference).ShowModal;
  finally
    TForm(Reference).Release;
  end;
end;

procedure CriaFormulario(InstanceClass: TComponentClass; TID: Integer; TModo: TModoExibicao; var Reference);
var
  NewSetting: TFormMode;
begin
  // Verifica se o Formulario ja foi Instanciado
  try
    NewSetting := TFormMode.Create;
    NewSetting.Modo := TModo;
    NewSetting.ID   := TID;
    Application.CreateForm(InstanceClass, Reference);
    //TForm(Reference).Settings := NewSetting;
    TForm(Reference).ShowModal;
  finally
    TForm(Reference).Release;
    FreeAndNil(NewSetting);
  end;
end;

end.
