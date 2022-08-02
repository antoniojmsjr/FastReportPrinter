library ISAPI;

uses
  System.SysUtils,
  System.Classes,
  Horse,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  frxClass,
  System.StrUtils,
  FRPrinter,
  FRPrinter.Types,
  Utils in '..\Utils\Utils.pas',
  Data in '..\Utils\Data.pas';

{$R *.res}

begin
  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Get('printer/:estadoid',
    procedure(pReq: THorseRequest; pRes: THorseResponse; pNext: TProc)
    var
      lFDConnection: TFDConnection;
      lQryEstadosBrasil: TFDQuery;
      lQryMunicipioEstado: TFDQuery;
      lQryMunicipioRegiao: TFDQuery;
      lQryEstadoRegiao: TFDQuery;
      lQryMunicipios: TFDQuery;
      lError: string;
      lFiltro: Integer;
      lPrinted: Boolean;
    begin
      lFiltro := pReq.Params.Field('estadoid').AsInteger;
      lFDConnection := nil;
      try
        lFDConnection := TFDConnection.Create(nil);

        //CONEXÃO COM O BANCO DE DADOS DE EXEMPLO
        if not TUtils.ConnectDB('127.0.0.1', TUtils.PathAppFileDB, lFDConnection, lError) then
        begin
          pRes.Send('Erro de conexão: ' + lError).Status(500);
          Exit;
        end;

        //CONSULTA BANCO DE DADOS
        try
          TData.QryEstadosBrasil(lFDConnection, lQryEstadosBrasil);
          TData.QryMunicipioEstado(lFDConnection, lQryMunicipioEstado);
          TData.QryMunicipioRegiao(lFDConnection, lQryMunicipioRegiao);
          TData.QryEstadoRegiao(lFDConnection, lQryEstadoRegiao);
          TData.QryMunicipios(lFDConnection, lQryMunicipios, lFiltro);
        except
          on E: Exception do
          begin
            pRes.Send(E.Message).Status(500);
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
                lfrxMemoView.Memo.Text := Format('Aplicativo de Exemplo: %s', ['ISAPI HORSE']);
              end;
            end).
            Execute; //PROCESSAMENTO DO RELATÓRIO/IMPRESSÃO
        except
          on E: Exception do
          begin
            if E is EFRPrinter then
              pRes.Send(E.ToString).Status(500)
            else
              pRes.Send(E.Message+' - '+E.QualifiedClassName).Status(500);
            Exit;
          end;
        end;

        if lPrinted then
          pRes.Send('Impresso').Status(200)
        else
          pRes.Send('Falha de impressão').Status(500);
      finally
        lFDConnection.Free;
      end;
    end);

  THorse.Listen;
end.
