unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, frxClass,
  FRPrinter, FRPrinter.Interfaces, FRPrinter.Types,
  Utils, Data;

type
  TsrvFastReportPrint = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  srvFastReportPrint: TsrvFastReportPrint;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvFastReportPrint.Controller(CtrlCode);
end;

function TsrvFastReportPrint.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvFastReportPrint.ServiceStart(Sender: TService; var Started: Boolean);
var
  lFDConnection: TFDConnection;
  lQryEstadosBrasil: TFDQuery;
  lQryMunicipioEstado: TFDQuery;
  lQryMunicipioRegiao: TFDQuery;
  lQryEstadoRegiao: TFDQuery;
  lQryMunicipios: TFDQuery;
  lError: string;
  lPrinted: Boolean;
begin
  Started := True;
  ReportStatus;

  Sleep(1000);

  LogMessage('Impressão Fast Report.', EVENTLOG_INFORMATION_TYPE, 0, 1050);

  lFDConnection := nil;
  try
    lFDConnection := TFDConnection.Create(nil);

    //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
    if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
    begin
      LogMessage('Erro de conexão: ' + lError, EVENTLOG_ERROR_TYPE, 0, 1050);
      Exit;
    end;

    //CONSULTA BANCO DE DADOS
    try
      TData.QryEstadosBrasil(lFDConnection, lQryEstadosBrasil);
      TData.QryMunicipioEstado(lFDConnection, lQryMunicipioEstado);
      TData.QryMunicipioRegiao(lFDConnection, lQryMunicipioRegiao);
      TData.QryEstadoRegiao(lFDConnection, lQryEstadoRegiao);
      TData.QryMunicipios(lFDConnection, lQryMunicipios);
    except
      on E: Exception do
      begin
        LogMessage(E.Message, EVENTLOG_ERROR_TYPE, 0, 1050);
        Exit;
      end;
    end;

    //CLASSE DE IMPRESSÃO
    try
      lPrinted := TFRPrinter.New.
      DataSets.
        SetDataSet(lQryEstadosBrasil, 'EstadosBrasil').
        SetDataSet(lQryMunicipioEstado, 'MunicipioEstado').
        SetDataSet(lQryMunicipioRegiao, 'MunicipioRegiao').
        SetDataSet(lQryEstadoRegiao, 'EstadoRegiao').
        SetDataSet(lQryMunicipios, 'Municipios').
      &End.
      Print.
        //SetPrinter('Microsoft Print to PDF'). //QUANDO NÃO INFORMADO UTILIZA A IMPRESSORA CONFIGURADA NO RELATÓRIO *.fr3
        SetFileReport(TUtils.PathAppFileReport). //LOCAL DO RELATÓRIO *.fr3
        Report(procedure(pfrxReport: TfrxReport) //CONFIGURAÇÃO DO COMPONENTE DE RELATÓRIO DO FAST REPORT
        var
          lfrxComponent: TfrxComponent;
          lfrxMemoView: TfrxMemoView absolute lfrxComponent;
        begin
          //CONFIGURAÇÃO DO COMPONENTE

          pfrxReport.ReportOptions.Name := 'API de localidades IBGE'; //NOME PARA IDENTIFICAÇÃO NA IMPRESSÃO DO RELATÓRIO
          pfrxReport.ReportOptions.Author := 'Antônio José Medeiros Schneider';

          //PASSAGEM DE PARÂMETRO PARA O RELATÓRIO
          lfrxComponent := pfrxReport.FindObject('mmoProcess');
          if Assigned(lfrxComponent) then
          begin
            lfrxMemoView.Memo.Clear;
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['WINDOWS SERVICE']);
          end;
        end).
        Execute; //PROCESSAMENTO DO RELATÓRIO/IMPRESSÃO
    except
      on E: Exception do
      begin
        if E is EFRPrinter then
          LogMessage('Erro de impressão: ' + E.ToString, EVENTLOG_ERROR_TYPE, 0, 1050)
        else
          LogMessage('Erro de impressão: ' + E.Message, EVENTLOG_ERROR_TYPE, 0, 1050);
        Exit;
      end;
    end;

    if lPrinted then
      LogMessage('Relatório impresso com sucesso.', EVENTLOG_INFORMATION_TYPE, 0, 1050)
    else
      LogMessage('Relatório falha de impressão.', EVENTLOG_INFORMATION_TYPE, 0, 1050);

  finally
    lFDConnection.Free;
  end;
end;

end.
