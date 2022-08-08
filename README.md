![Maintained YES](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square&color=important)
![Memory Leak Verified YES](https://img.shields.io/badge/Memory%20Leak%20Verified%3F-yes-green.svg?style=flat-square&color=important)
![Release](https://img.shields.io/github/v/release/antoniojmsjr/FastReportPrinter?label=Latest%20release&style=flat-square&color=important)
![Stars](https://img.shields.io/github/stars/antoniojmsjr/FastReportPrinter.svg?style=flat-square)
![Forks](https://img.shields.io/github/forks/antoniojmsjr/FastReportPrinter.svg?style=flat-square)
![Issues](https://img.shields.io/github/issues/antoniojmsjr/FastReportPrinter.svg?style=flat-square&color=blue)</br>
![Compatibility](https://img.shields.io/badge/Compatibility-VCL,%20Firemonkey,%20DataSnap,%20Horse,%20RDW,%20RADServer-3db36a?style=flat-square)
![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE7%20and%20above-3db36a?style=flat-square)
![FastReport Supported Versions](https://img.shields.io/badge/Fast%20Report%20Supported%20Versions-5.1.5%20and%20above-3db36a?style=flat-square)

# FastReportPrinter

**FastReportPrinter** é uma biblioteca de impressão de relatórios com [Fast Report](https://www.fast-report.com) para ambientes **multithreading** e não **GUI(Graphical User Interface)**.

Implementado na linguagem Delphi, utiliza o conceito de [fluent interface](https://en.wikipedia.org/wiki/Fluent_interface) para guiar no uso da biblioteca, desenvolvido para impressão de relatórios em ambientes não GUI(Graphical User Interface) usando spooler de impressão.

**Ambientes**

* Windows Forms
* Windows Console
* Windows Service *
* IIS ISAPI[(Horse)](https://github.com/HashLoad/horse) *
* IIS CGI[(Horse)](https://github.com/HashLoad/horse) *

## ⭕ Pré-requisito

Para utilizar o **FastReportPrinter** é necessário a instalação do componente [Fast Report](https://www.fast-report.com).

## ⚙️ Instalação Automatizada

Utilizando o [**Boss**](https://github.com/HashLoad/boss/releases/latest) (Dependency manager for Delphi) é possível instalar a biblioteca de forma automática.

```
boss install github.com/antoniojmsjr/FastReportPrinter
```

## ⚙️ Instalação Manual

Se você optar por instalar manualmente, basta adicionar as seguintes pastas ao seu projeto, em *Project > Options > Delphi Compiler > Target > All Configurations > Search path*

```
..\FastReportPrinter\Source
```

## 🧬 DataSet de Exportação

**DataSets** é uma interface utilizada pela biblioteca para comunicação com o banco de dados através dos componentes:

| Classe | Componente |
|---|---|
| TDataSet | Nativo |
| TfrxDBDataset | Fast Report |

## ⚡️ Uso da biblioteca

Para exemplificar o uso do biblioteca foi utilizado os dados da **[API de localidades do IBGE](https://servicodados.ibge.gov.br/api/docs/localidades)** para geração e impressão do relatório.

Arquivo de exemplo de impressão: [LocalidadesIBGE.pdf](https://github.com/antoniojmsjr/FastReportPrinter/files/9245473/LocalidadesIBGE.pdf)

Os exemplos estão disponíveis na pasta do projeto:

```
..\FastReportPrinter\Samples
```

**Banco de dados de exemplo**

* Firebird: 2.5.7 [Donwload](http://sourceforge.net/projects/firebird/files/firebird-win32/2.5.7-Release/Firebird-2.5.7.27050_0_Win32.exe/download)
* Arquivo BD:
```
..\FastReportPrinter\Samples\DB
```

**Relatório de exemplo**

```
..\FastReportPrinter\Samples\Report
```
**Exemplo**

```delphi
uses FRPrinter, FRPrinter.Types;
```
```delphi
var
  lPrinted: Boolean;
begin

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
        SetPrinter('Microsoft Print to PDF'). //QUANDO NÃO INFORMADO UTILIZA A IMPRESSORA CONFIGURADA NO RELATÓRIO *.fr3
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
```

**Observação**

* Falta de memória pode gerar falha de impressão.
* Impressão de documento grande pode ter demora na resposta de sucesso da impressão.
* Windows Service Application é necessário configurar "logon" usando uma conta administrativa ou NT AUTHORITY\LocalService e ou NT AUTHORITY\NetworkService para uma impressão com sucesso.
* IIS(ISAPI/CGI) devido a um [bug](https://blogs.stonesteps.ca/1/p/44) quando app 32 bits e Windows 64 bits não é possível imprimir, solução, compilar app 64 bits e com permissão usando uma conta NT AUTHORITY\LocalService e ou NT AUTHORITY\NetworkService.

**Exemplo compilado**

* VCL
* VCL [(Horse)](https://github.com/HashLoad/horse)

Download: [Demo.zip](https://github.com/antoniojmsjr/FastReportPrinter/files/9245293/Demo.zip)



https://user-images.githubusercontent.com/20980984/183212903-ec64169a-f1f5-4c21-8c46-bc3e5a8c8078.mp4



https://user-images.githubusercontent.com/20980984/183213069-68c4ca35-4804-481e-854e-e7d1ae303686.mp4



**Teste de desempenho para aplicações web usando [JMeter](https://jmeter.apache.org/):**

```
..\FastReportPrinter\Samples\JMeter
```


## ⚠️ Licença
`FastReportPrinter` is free and open-source software licensed under the [![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://github.com/antoniojmsjr/FastReportPrinter/blob/main/LICENSE)
