{******************************************************************************}
{                                                                              }
{           FRPrinter.Types                                                    }
{                                                                              }
{           Copyright (C) Antônio José Medeiros Schneider Júnior               }
{                                                                              }
{           https://github.com/antoniojmsjr/FastReportPrinter                  }
{                                                                              }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit FRPrinter.Types;

interface

uses
  frxClass, System.Classes, System.SysUtils;

type
  TFRPrinterReportCallback = reference to procedure(frxReport: TfrxReport);

  EFRPrinter = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
    FMessage: string;
  public
    { public declarations }
  end;

  EFRPrinterFileReport = class(EFRPrinter)
  private
    { private declarations }
    FFileName: string;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pFileName: string; const pMessage: string);
    function ToString: string; override;
    property FileName: string read FFileName;
  end;

  EFRPrinterPrint = class(EFRPrinter)
  private
    { private declarations }
    FPrinterName: string;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pPrinterName: string; const pMessage: string);
    function ToString: string; override;
    property PrinterName: string read FPrinterName;
  end;

  EFRPrinterPrepareReport = class(EFRPrinter)
  private
    { private declarations }
    FMessages: TStrings;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pMessages: TStrings);
    destructor Destroy; override;
    function ToString: string; override;
    property Messages: TStrings read FMessages;
  end;

implementation

{$REGION 'EFRPrinterPrint'}
constructor EFRPrinterPrint.Create(const pPrinterName: string;
  const pMessage: string);
begin
  inherited Create('See ToString.');
  FPrinterName := pPrinterName;
  FMessage := pMessage;
end;

function EFRPrinterPrint.ToString: string;
begin
  Result := EmptyStr;
  Result := Concat(Result, 'Printer Print', sLineBreak, sLineBreak);
  Result := Concat(Result, 'Printer Name: ', FPrinterName, sLineBreak);
  Result := Concat(Result, 'Message: ', FMessage);
end;
{$ENDREGION}

{$REGION 'EFRPrinterPrepareReport'}
constructor EFRPrinterPrepareReport.Create(const pMessages: TStrings);
begin
  inherited Create('See ToString.');

  FMessages := TStringList.Create;
  FMessages.AddStrings(pMessages);
end;

destructor EFRPrinterPrepareReport.Destroy;
begin
  FMessages.Free;
  inherited Destroy;
end;

function EFRPrinterPrepareReport.ToString: string;
var
  I: Integer;
begin
  Result := EmptyStr;
  Result := Concat(Result, 'Printer Prepare Report', sLineBreak, sLineBreak);
  for I := 0 to Pred(FMessages.Count) do
    Result := Concat(Result, '* ', FMessages.Strings[I], sLineBreak);
end;
{$ENDREGION}

{$REGION 'EFRPrinterFileReport'}
constructor EFRPrinterFileReport.Create(const pFileName: string;
  const pMessage: string);
begin
  inherited Create('See ToString.');
  FFileName := pFileName;
  FMessage := pMessage;
end;

function EFRPrinterFileReport.ToString: string;
begin
  Result := EmptyStr;
  Result := Concat(Result, 'Printer File', sLineBreak, sLineBreak);
  Result := Concat(Result, 'File: ', FFileName, sLineBreak);
  Result := Concat(Result, 'Message: ', FMessage);
end;
{$ENDREGION}

end.
