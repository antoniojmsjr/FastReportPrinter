unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TfrmMain = class(TForm)
    lytHeader: TLayout;
    btnImprimir: TButton;
    btnImprimirThread: TButton;
    procedure btnImprimirThreadClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
  private
    { Private declarations }
    procedure PrintReportThread;
    procedure PrintReport;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Utils, Data, FRPrinter, FRPrinter.Types, System.Threading, frxClass;

{$R *.fmx}

{ TfrmMain }

procedure TfrmMain.btnImprimirClick(Sender: TObject);
begin
  PrintReport;
end;

procedure TfrmMain.btnImprimirThreadClick(Sender: TObject);
begin
  PrintReportThread;
end;

procedure TfrmMain.PrintReport;
var
  lFDConnection: TFDConnection;
  lQryEstadosBrasil: TFDQuery;
  lQryMunicipioEstado: TFDQuery;
  lQryMunicipioRegiao: TFDQuery;
  lQryEstadoRegiao: TFDQuery;
  lQryMunicipios: TFDQuery;
  lPrinted: Boolean;
  lError: string;
begin
  lFDConnection := nil;
  try
    lFDConnection := TFDConnection.Create(nil);

    //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
    if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
    begin
      ShowMessage('Erro de conexão: ' + lError);
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
        ShowMessage(E.Message);
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
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['FMX']);
          end;
        end).
        Execute; //PROCESSAMENTO DO RELATÓRIO/IMPRESSÃO
    except
      on E: Exception do
      begin
        if E is EFRPrinter then
          ShowMessage('Erro de impressão: ' + E.ToString)
        else
          ShowMessage('Erro de impressão: ' + E.Message);
        Exit;
      end;
    end;

    if lPrinted then
      ShowMessage('Impresso')
    else
      ShowMessage('Falha de impressão');
  finally
    lFDConnection.Free;
  end;
end;

procedure TfrmMain.PrintReportThread;
var
  lTask: ITask;
begin
  lTask := TTask.Create(
  procedure
  var
    lFDConnection: TFDConnection;
    lQryEstadosBrasil: TFDQuery;
    lQryMunicipioEstado: TFDQuery;
    lQryMunicipioRegiao: TFDQuery;
    lQryEstadoRegiao: TFDQuery;
    lQryMunicipios: TFDQuery;
    lPrinted: Boolean;
    lPrinterError: Boolean;
    lPrinterErrorMessage: string;
    lError: string;
    procedure ShowMessageThread(const pText: string);
    begin
      TThread.Synchronize(TThread.Current,
      procedure
      begin
        ShowMessage(pText);
      end);
    end;
  begin
    lPrinterError := False;
    lFDConnection := nil;
    try
      lFDConnection := TFDConnection.Create(nil);

      //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
      if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
      begin
        lPrinterErrorMessage := 'Erro de conexão: ' + lError;
        ShowMessageThread(lPrinterErrorMessage);
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
          lPrinterErrorMessage := 'Erro de consulta: ' + lError;
          ShowMessageThread(lPrinterErrorMessage);
          Exit;
        end;
      end;

      //CLASSE DE EXPORTAÇÃO
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
          SetPrinter('Microsoft Print to PDF'). //[OPCIONAL]: QUANDO NÃO INFORMADO UTILIZADO IMPRESSORA DEFAULT
          SetFileReport(TUtils.PathAppFileReport). //LOCAL DO RELATÓRIO *.fr3
          Report(procedure(pfrxReport: TfrxReport) //CONFIGURAÇÃO DO COMPONENTE DE RELATÓRIO DO FAST REPORT
          var
            lfrxComponent: TfrxComponent;
            lfrxMemoView: TfrxMemoView absolute lfrxComponent;
          begin
            //CONFIGURAÇÃO DO COMPONENTE
            pfrxReport.ReportOptions.Author := 'Antônio José Medeiros Schneider';

            //PASSAGEM DE PARÂMETRO PARA O RELATÓRIO
            lfrxComponent := pfrxReport.FindObject('mmoProcess');
            if Assigned(lfrxComponent) then
            begin
              lfrxMemoView.Memo.Clear;
              lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['FMX']);
            end;
          end).
          Execute; //PROCESSAMENTO DO RELATÓRIO/IMPRESSÃO
      except
        on E: Exception do
        begin
          lPrinterError := True;
          if E is EFRPrinter then
            lPrinterErrorMessage := E.ToString
          else
            lPrinterErrorMessage := E.Message;
        end;
      end;

      if lPrinterError then
      begin
        TThread.Synchronize(TThread.Current,
        procedure
        begin
          ShowMessage('Erro de impressão: ' + lPrinterErrorMessage);
        end);
        Exit;
      end;

      TThread.Synchronize(TThread.Current,
        procedure
        begin
          if lPrinted then
            ShowMessage('Impresso')
          else
            ShowMessage('Falha de impressão');
        end);
    finally
      lFDConnection.Free;
    end;
  end);
  lTask.Start;
end;

end.
