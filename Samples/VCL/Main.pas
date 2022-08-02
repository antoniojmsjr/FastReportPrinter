unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Comp.DataSet, frxClass,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, frxRich, frxADOComponents,
  frxDBXComponents, frxIBXComponents, frxDBSet;

type
  TfrmMain = class(TForm)
    frxReport: TfrxReport;
    qryMunicipioEstado: TFDQuery;
    conFastReportPrint: TFDConnection;
    pnlMain: TPanel;
    btnConectarDB: TButton;
    btnImprimir: TButton;
    ckbImprimirThread: TCheckBox;
    frxdbMunicipioEstado: TfrxDBDataset;
    qryMunicipioRegiao: TFDQuery;
    frxdbMunicipioRegiao: TfrxDBDataset;
    qryEstadoRegiao: TFDQuery;
    frxDBEstadoRegiao: TfrxDBDataset;
    qryEstadosBrasil: TFDQuery;
    frxdbEstadosBrasil: TfrxDBDataset;
    qryMunicipios: TFDQuery;
    frxdbMunicipios: TfrxDBDataset;
    edtPrinterName: TEdit;
    procedure btnImprimirClick(Sender: TObject);
    procedure btnConectarDBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure PrintThread;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Utils, FRPrinter, FRPrinter.Types,
  System.Generics.Collections, System.Threading;

{$R *.dfm}

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  conFastReportPrint.Close;
end;

procedure TfrmMain.btnConectarDBClick(Sender: TObject);
begin
  conFastReportPrint.Open;

  qryEstadosBrasil.Close;
  qryEstadosBrasil.Open;

  qryMunicipioEstado.Close;
  qryMunicipioEstado.Open;

  qryMunicipioRegiao.Close;
  qryMunicipioRegiao.Open;

  qryEstadoRegiao.Close;
  qryEstadoRegiao.Open;

  qryMunicipios.Close;
  qryMunicipios.Open;

  btnImprimir.Enabled := True;
end;

procedure TfrmMain.btnImprimirClick(Sender: TObject);
var
  lPrinted: Boolean;
begin

  if ckbImprimirThread.Checked then
  begin
    PrintThread;
    Exit;
  end;

  //CLASSE DE IMPRESSÃO
  try
    lPrinted := TFRPrinter.New.
      DataSets.
        SetDataSet(qryEstadosBrasil, 'EstadosBrasil').
        SetDataSet(frxdbMunicipioEstado).
        SetDataSet(frxdbMunicipioRegiao).
        SetDataSet(qryEstadoRegiao, 'EstadoRegiao').
        SetDataSet(qryMunicipios, 'Municipios').
      &End.
      Print.
        SetPrinter(edtPrinterName.Text). //QUANDO NÃO INFORMADO UTILIZA A IMPRESSORA CONFIGURADA NO RELATÓRIO *.fr3
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
            lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['VCL']);
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
end;

procedure TfrmMain.PrintThread;
var
  lTask: ITask;
begin
  lTask := TTask.Create(
  procedure
  var
    lPrinted: Boolean;
    lPrinterError: Boolean;
    lPrinterErrorMessage: string;
  begin
    lPrinterError := False;

    //CLASSE DE IMPRESSÃO
    try
      lPrinted := TFRPrinter.New.
        DataSets.
          SetDataSet(qryEstadosBrasil, 'EstadosBrasil').
          SetDataSet(frxdbMunicipioEstado).
          SetDataSet(frxdbMunicipioRegiao).
          SetDataSet(qryEstadoRegiao, 'EstadoRegiao').
          SetDataSet(qryMunicipios, 'Municipios').
        &End.
        Print.
          SetPrinter('CutePDF Writer'). //[OPCIONAL]: QUANDO NÃO INFORMADO UTILIZADO IMPRESSORA DEFAULT
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
              lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['VCL']);
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
  end);
  lTask.Start;
end;

end.
