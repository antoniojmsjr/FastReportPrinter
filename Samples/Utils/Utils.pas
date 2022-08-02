unit Utils;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,

  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Phys.IBWrapper;

type

  TUtils = class sealed
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function PathAppFileDB: string;
    class function PathAppFileReport: string;
    class function PathApp: string;
    class function PathAppFile: string;
    class function ConnectDB(const pServer: string; const pDataBase: string;
                             pFDConnection: TFDConnection; out poError: string): Boolean;
    class function QueryOpen(pQuery: TFDQuery; const pSQL: string; out poError: string): Boolean; static;
  end;

implementation

{ TUtils }

class function TUtils.ConnectDB(const pServer: string; const pDataBase: string;
  pFDConnection: TFDConnection; out poError: string): Boolean;
var
  lFBConnectionDefParams: TFDPhysFBConnectionDefParams; // FIREBIRD CONNECTION PARAMS
begin
  Result := False;

  lFBConnectionDefParams := TFDPhysFBConnectionDefParams(pFDConnection.Params);
  lFBConnectionDefParams.DriverID := 'FB';
  lFBConnectionDefParams.Server := pServer;
  lFBConnectionDefParams.Database := pDataBase;
  lFBConnectionDefParams.UserName := 'SYSDBA';
  lFBConnectionDefParams.Password := 'masterkey';
  lFBConnectionDefParams.Protocol := TIBProtocol.ipLocal;

  pFDConnection.FetchOptions.Mode := TFDFetchMode.fmAll; //fmAll
  pFDConnection.ResourceOptions.AutoConnect := False;
  pFDConnection.ResourceOptions.SilentMode := True;

  try
    pFDConnection.Open;
    Result := True;
  except
    on E: Exception do
      poError := E.Message;
  end;
end;

class function TUtils.QueryOpen(pQuery: TFDQuery;
  const pSQL: string; out poError: string): Boolean;
begin
  Result := False;
  try
    pQuery.Close;
    pQuery.SQL.Clear;
    pQuery.SQL.Add(pSQL);
    pQuery.Open;
    Result := True;
  except
    on E: Exception do
      poError := E.Message;
  end;
end;

class function TUtils.PathApp: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(PathAppFile));
end;

class function TUtils.PathAppFileDB: string;
var
  lPathApp: string;
  lPos: Integer;
begin
  lPathApp := Self.PathApp;
  lPos := Pos('fastreportprinter', LowerCase(lPathApp));
  lPathApp := IncludeTrailingPathDelimiter(Copy(lPathApp, 1, (lPos + Length('FastReportPrinter'))));
  Result := lPathApp + 'Samples\DB\FAST_REPORT_PRINTER.FDB';
end;

class function TUtils.PathAppFileReport: string;
var
  lPathApp: string;
  lPos: Integer;
begin
  lPathApp := Self.PathApp;
  lPos := Pos('fastreportprinter', LowerCase(lPathApp));
  lPathApp := IncludeTrailingPathDelimiter(Copy(lPathApp, 1, (lPos + Length('FastReportPrinter'))));
  Result := lPathApp + 'Samples\Report\rptLocalidadesIBGE.fr3';
end;

class function TUtils.PathAppFile: string;
var
  lFileName: array[0..MAX_PATH] of Char;
  lReturn: Cardinal;
begin

  //DELPHI PACKAGE
  if ModuleIsPackage then begin
    Result := ParamStr(0);
  end
  else //EXE/DLL
  begin
    FillChar(lFileName, SizeOf(lFileName), #0);
    lReturn := GetModuleFileName(HInstance, lFileName, MAX_PATH);

    if (lReturn > 0) then
      Result := string(lFileName)
    else
      raise Exception.Create(SysErrorMessage(GetLastError));
  end;

  //IIS
  if Result.StartsWith('\\?\') then
    Delete(Result, 1, 4);
end;

end.
