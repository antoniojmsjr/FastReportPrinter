{******************************************************************************}
{                                                                              }
{           FRPrinter.Interfaces                                               }
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
unit FRPrinter.Interfaces;

interface

uses
  System.Classes, Data.DB, frxClass, frxDBSet, FRPrinter.Types;

type
  IFRPrinterExecute = interface;
  IFRPrinterDataSets = interface;

  IFRPrinter = interface
    ['{7DAE128C-3F08-447C-888A-8D5F5BBF1DDA}']
    function GetFRPrintertDataSets: IFRPrinterDataSets;
    function GetFRPrinterExecute: IFRPrinterExecute;

    property DataSets: IFRPrinterDataSets read GetFRPrintertDataSets;
    property Print: IFRPrinterExecute read GetFRPrinterExecute;
  end;

  IFRPrinterDataSets = interface
    ['{352279D1-95C5-41B7-82E0-EBBB2E09890D}']
    function GetEnd: IFRPrinter;
    function SetDataSet(DataSet: TDataSet; const UserName: string): IFRPrinterDataSets; overload;
    function SetDataSet(DataSet: TfrxDBDataset): IFRPrinterDataSets; overload;

    property &End: IFRPrinter read GetEnd;
  end;

  IFRPrinterExecute = interface
    ['{639633AE-9972-4589-86D6-0EF515BCD344}']
    function SetExceptionFastReport(const Value: Boolean): IFRPrinterExecute;
    function SetPrinter(const PrinterName: string): IFRPrinterExecute;
    function SetFileReport(const FileName: string): IFRPrinterExecute; overload;
    function SetFileReport(FileStream: TStream): IFRPrinterExecute; overload;
    function Report(const CallbackReport: TFRPrinterReportCallback): IFRPrinterExecute;
    function Execute: Boolean;
  end;

implementation

end.
