unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, IBConnection, FileUtil, SynEdit, Forms,
  Controls, Graphics, Dialogs, StdCtrls, DBGrids, ExtCtrls, Buttons, ActnList,
  ComCtrls, fpjson, jsonparser, uHistory;

type

  { TForm1 }

  TForm1 = class(TForm)
    Config: TAction;
    Memo1: TMemo;
    Menu2: TAction;
    Menu1: TAction;
    Locate: TAction;
    NewFolder: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    ImageList1: TImageList;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Splitter2: TSplitter;
    SQLConnector1: TSQLConnector;
    SQLQuery1: TSQLQuery;
    SQLScript1: TSQLScript;
    SQLTransaction1: TSQLTransaction;
    TabSheet1: TTabSheet;
    procedure BitBtn1Click(Sender: TObject);
    procedure ConfigExecute(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ExecutaComando( cComando: String );
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LocateExecute(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuExecute(Sender: TObject);
    procedure NewFolderExecute(Sender: TObject);
    function TemAtributo(Attr, Val: Integer): Boolean;
    procedure FuncDir(Diretorio: string; Sub:Boolean);
    procedure FuncDirFolders();
    procedure FuncMudaPasta( cPasta: String );
    function Pasta(): String;
    procedure Help();
    procedure getHistory;
    procedure getVersion;
    function Version(): String;
    procedure newPageFolder;
    procedure memo( cStr: String );


  private

  public

  end;

var
  Form1: TForm1;
  FrmHistory: TFrmHistory;
  PastaAtual: String;
  HistoricoAtual: Integer;

implementation
  uses uclassexportjson;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
  begin
     ExecutaComando( Edit1.text );
  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin

end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key = 27 then
  begin
     if Edit1.Focused then
        Edit1.Text:= '';
  end;

  if Key = 38 then // Seta para cima
  begin
     if ( HistoricoAtual+1 < FrmHistory.CheckListBox1.items.count ) then
     begin
         inc( HistoricoAtual );
     end
     else
     begin
         HistoricoAtual:= 0;
     end;
     Edit1.Text:= FrmHistory.CheckListBox1.items[HistoricoAtual];
     Edit1.SelStart:= Length( Edit1.Text );
  end;

  if Key = 40 then // Seta para baixo
  begin
     if ( HistoricoAtual > 0 ) then
     begin
         dec( HistoricoAtual );
     end
     else
     begin
         HistoricoAtual:= FrmHistory.CheckListBox1.items.count-1;
     end;
     Edit1.Text:= FrmHistory.CheckListBox1.items[HistoricoAtual];
     Edit1.SelStart:= Length( Edit1.Text );
  end;

end;

procedure TForm1.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then
  begin
     if Edit1.canFocus then
        Edit1.setFocus;
  end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin

end;

procedure TForm1.ConfigExecute(Sender: TObject);
begin
  Help();
end;

function TForm1.Pasta(): String;
begin
   result:= PastaAtual;
end;

procedure TForm1.FuncDir(Diretorio: string; Sub:Boolean);
var
  F: TSearchRec;
  Ret: Integer;
  TempNome: string;
  caminho: string;
begin
  caminho:= Diretorio + '*.*';
  memo( 'dir.folder.files=' + caminho );
  Ret := FindFirst( caminho, faAnyFile, F);
  while Ret = 0 do
  begin
        if TemAtributo(F.Attr, faDirectory) then
        begin

          if (F.Name <> '.') And (F.Name <> '..') then
          begin
             if Sub = True then
             begin
                TempNome := Diretorio + F.Name;
                FuncDir( TempNome, True);
             end;
          end;
        end
        else
        begin
           memo( Diretorio + F.Name );
        end;
        Ret := FindNext(F);
   end;
end;

procedure TForm1.FuncDirFolders();
var
    searchResult : TSearchRec;
begin
    // Try to find directories above the current directory
    SetCurrentDir( pasta() );
    memo( 'dir.folder.folders=' + pasta() );
    if findfirst('*', faDirectory, searchResult) = 0 then
    begin
      repeat
        // Only show directories
        if (searchResult.attr and faDirectory) = faDirectory
        then if searchResult.Name <> '.' then if searchResult.Name <> '..' then
            memo('Dir = '+searchResult.Name);
      until FindNext(searchResult) <> 0;

      // Must free up resources used by these successful finds
      FindClose(searchResult);
    end;
  end;



function TForm1.TemAtributo(Attr, Val: Integer): Boolean;
begin
          Result := Attr and Val = Val;
end;

procedure TForm1.FuncMudaPasta( cPasta: String );
begin
   if pos( '/', cPasta ) <= 1 then
   begin
      pastaAtual:= cPasta;
   end
   else
   begin
      pastaAtual:= pastaAtual + cPasta;
   end;
   memo( '->' + pastaAtual );
end;

procedure TForm1.ExecutaComando( cComando: String );
var
  cData, cUser, cHost, cPass: String;
  Exportjson: TClassExportJson;
  i: integer;
  j: integer;
begin
  FrmHistory.Add( cComando );
  if UpperCase( copy( cComando, 1, 3 ) ) = 'CD ' then
  begin
     // Busca arquivos
     memo( cComando );
     FuncMudaPasta( trim( copy( cComando, 3, 9999 ) ) );
  end;
  if UpperCase( copy( cComando, 1, 3 ) ) = 'DIR' then
  begin
     // Busca arquivos
     memo( cComando + ' ' + Pasta() );
     FuncDirFolders();
     FuncDir( pastaAtual, false );
  end;
  if ( ( UpperCase( copy( cComando, 1, 8 ) ) = 'MAXIMIZE' ) OR
       ( UpperCase( copy( cComando, 1, 3 ) ) = 'MAX' ) ) then
  begin
     // Maximiza tela
     memo( cComando );
     WindowState:= wsMaximized;
     Application.processMessages;
  end;
  if UpperCase( copy( cComando, 1, 4 ) ) = 'HELP' then
  begin
     Help;
  end;
  if UpperCase( copy( cComando, 1, 4 ) ) = 'NEXT' then
  begin
     // Next
     if SQLQuery1.Active then
     begin
        SQLQuery1.Next;
     end;
  end
  else if UpperCase( copy( cComando, 1, 3 ) ) = 'EOF' then
  begin
     if SQLQuery1.Active then
     begin
        if SQLQuery1.EOF then
           memo( 'true' )
        else
           memo( 'false' );
     end;
  end
  else if UpperCase( copy( cComando, 1, 3 ) ) = 'BOF' then
  begin
     if SQLQuery1.Active then
     begin
        if SQLQuery1.BOF then
           memo( 'true' )
        else
           memo( 'false' );
     end;
  end
  else if UpperCase( copy( cComando, 1, 4 ) ) = 'JSON' then
  begin
     if SQLQuery1.Active then
     begin
        Exportjson:= TClassExportJson.Create;
        Exportjson.Query:= SQLQuery1;
        memo( Exportjson.Execute().Text );
     end;
  end
  else if ( UpperCase( copy( cComando, 1, 1 ) ) = 'T' ) and
          ( length( trim( cComando ) ) < 3 ) and
          ( pos( copy( cComando, 2, 1 ), '01234567890' )>0 ) then
  begin
     j:= strtoint( trim( copy( cComando, 2, 3 ) ) );
     for i:= 0 to PageControl1.PageCount - 1 do
     begin
        if ( i = j-1 ) then
        begin
          PageControl1.activePageIndex:= i;
          memo( 'TO ' + 'Tab' + IntToStr( j ) );
        end;
     end;
  end
  else if UpperCase( copy( cComando, 1, 3 ) ) = 'NEW' then
  begin
     newPageFolder();
  end;
  if UpperCase( copy( cComando, 1, 5 ) ) = 'FIRST' then
  begin
     if SQLQuery1.Active then
     begin
        SQLQuery1.First;
     end;
  end;
  if UpperCase( copy( cComando, 1, 4 ) ) = 'LAST' then
  begin
     if SQLQuery1.Active then
     begin
        SQLQuery1.Last;
     end;
  end;
  if UpperCase( copy( cComando, 1, 5 ) ) = 'PRIOR' then
  begin
     if SQLQuery1.Active then
     begin
        SQLQuery1.Prior;
     end;
  end;
  if UpperCase( copy( cComando, 1, 3 ) ) = 'HIS' then
  begin
     GetHistory;
  end;
  if UpperCase( copy( cComando, 1, 3 ) ) = 'VER' then
  begin
     GetVersion;
  end;

  if UpperCase( copy( cComando, 1, 5 ) ) = 'CLOSE' then
  begin
     // Maximiza tela
     memo( cComando );
     SQLQuery1.Close;
  end;

  if UpperCase( copy( cComando, 1, 8 ) ) = 'MAXIMIZE' then
  begin
     // Maximiza tela
     memo( cComando );
     WindowState:= wsMaximized;
     Application.processMessages;
  end;

  if UpperCase( copy( cComando, 1, 8 ) ) = 'SHOW TAB' then
  begin
     // Maximiza tela
    memo( cComando );

    // FORMATO 1
    cComando:= 'SELECT rdb$relation_name AS TABELA'+
                '        FROM rdb$relations '+
                '        WHERE rdb$system_flag = 0 '+ //  somente objetos de usuário
                '            and rdb$relation_type = 0 '; //-- somente tabelas;

    // FORMATO 2, FIREBIRD 1.5 compatible
    cComando:= 'select  DISTINCT r.rdb$relation_name as TABELA ' +
                 ' from rdb$relations r  ' +
                 ' join rdb$indices i on (i.rdb$relation_name = r.rdb$relation_name) ' +
                 ' WHERE SUBSTRING( r.rdb$relation_name FROM  1 FOR 4 ) != ' + QuotedStr('RDB$');

    SQLQuery1.SQL.clear;
     SQLQuery1.Close;
     SQLQuery1.SQL.Add( cComando );
     try
       SQLQuery1.Open;
       if SQLQuery1.Active then
       begin
         memo( 'Executando comando ' + cComando );
         while not SQLQuery1.eof do
         begin
            memo( SQLQuery1.FieldByName( 'TABELA' ).AsString );
            SQLQuery1.next;
         end;
       end;

     except on E: Exception do
        memo( 'Erro: ' + e.message + ' executando ' + cComando );
     end;
  end;


  if UpperCase( copy( cComando, 1, 4 ) ) = 'BROW' then // BROWSER
  begin
    // Foco no grid
     memo( cComando );
     if DBGrid1.CanFocus then
        DBGrid1.SetFocus;
     Edit1.text:= '';
  end;
  if UpperCase( copy( cComando, 1, 3 ) ) = 'CLS' then
  begin
     // Limpar
     Memo1.lines.clear;
  end
  else if UpperCase( copy( cComando, 1, 13 ) ) = 'CLEAR HISTORY' then
  begin
      FrmHistory.Limpa;
  end
  else if UpperCase( copy( cComando, 1, 5 ) ) = 'CLEAR' then
  begin
     // Limpar
     Memo1.lines.clear;
  end
  else if UpperCase( copy( cComando, 1, 3 ) ) = 'USE' then
  begin
     cUser:= 'SYSDBA';
     cPass:= 'masterkey';
     cHost:= 'localhost';
     if UpperCase( trim( cComando ) ) = 'USE' then
     begin
       if OpenDialog1.Execute then
       begin
          cData:= OpenDialog1.FileName;
       end;
     end
     else
     begin
       cData:= trim( copy( cComando, pos( ' ', cComando )+1, 100 ) );
       if pos( ' ', cData ) > 0 then
          cData:= copy( cData, 0, pos(' ', cData )-1 );
       if pos( ':', cData ) > 0 then
          cHost:= copy( cData, 0, pos(':', cData )-1 );
       if pos( ':', cData ) > 0 then
          cData:= trim( copy( cData, pos(':', cData )+1 ) );
     end;
     if pos( '-u', cComando ) > 0 then
     begin
         cUser:= copy( cComando, pos('-u', cComando )+2 );
         cUser:= trim( cUser );
         cUser:= copy( cUser, 0, pos( ' ', cUser )-1 );
     end;
     if pos( '-p', cComando ) > 0 then
     begin
         cPass:= copy( cComando, pos('-p', cComando )+2 );
         cPass:= trim( cPass ) + ' ';
         cPass:= copy( cPass, 0, pos( ' ', cPass )-1 );
     end;
     memo( 'Parametros ' + cUser + '/' + cPass + '@' + cHost + ':' + cData );
     // Conecta ao banco
     if SQLConnector1.ConnectorType = '' then
        SQLConnector1.ConnectorType:='Firebird';     
     SQLConnector1.hostname:= cHost;
     SQLConnector1.username:= cUser;
     SQLConnector1.password:= cPass;
     SQLConnector1.databasename:= cData;
     SQLConnector1.Open;
     memo( 'Conectado em ' + SQLConnector1.databasename );

  end;
  if UpperCase( copy( cComando, 1, 6 ) ) = 'SELECT' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        SQLQuery1.SQL.clear;
        SQLQuery1.Close;
        SQLQuery1.SQL.Add( cComando );
        try
          SQLQuery1.Open;
          if SQLQuery1.Active then
             memo( 'Executando comando ' + cComando );

        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'INSERT' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        SQLQuery1.SQL.clear;
        SQLQuery1.Close;
        SQLQuery1.SQL.Add( cComando );
        try
          SQLQuery1.ExecSQL;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'UPDATE' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        SQLQuery1.SQL.clear;
        SQLQuery1.Close;
        SQLQuery1.SQL.Add( cComando );
        try
          SQLQuery1.ExecSQL;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 4 ) ) = 'EXIT' then
  begin
     Close;
  end;

  if UpperCase( copy( cComando, 1, 4 ) ) = 'QUIT' then
  begin
     Close;
  end;

  if UpperCase( copy( cComando, 1, 4 ) ) = 'HIST' then
  begin
     DBGrid1.Height:= DBGrid1.Height-100;
     Application.processMessages;
     Edit1.Align:=alBottom;
  end;


  if UpperCase( copy( cComando, 1, 6 ) ) = 'DELETE' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else if pos( 'WHERE ', UpperCase( cComando ) ) <= 0 then
     begin
        memo( 'Você precisa de superpoderes para usar DELETE sem WHERE' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 5 ) ) = 'ALTER' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 4 ) ) = 'DROP' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'CREATE' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'COMMIT' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        memo( 'Banco desconectado' );
     end
     else
     begin
        //SQLScript1.Script.clear;
        //SQLScript1.Script.Add( cComando );
        try
          SQLTransaction1.commit;
          memo( 'Executando comando ' + cComando );
        except on E: Exception do
           memo( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;


end;

function TForm1.Version(): String;
begin
  result:= 'wsBase v1.0.02';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Caption:= Version() ;
   memo1.Lines.clear;
   HistoricoAtual:= -1;
end;

procedure TForm1.FormShow(Sender: TObject);
var
   cPar: String;
begin
  cPar:= ParamStr(1);
  if ( cPar <> '' ) then
  begin
    Edit1.text:= 'USE ' + cPar;
  end;
  FrmHistory:= tFrmHistory.Create( Application );
  Edit1.SetFocus;
end;

procedure TForm1.LocateExecute(Sender: TObject);
begin
  GetHistory;
end;


procedure TForm1.getHistory;
begin
  if FrmHistory.ShowModal = mrOk then
  begin
     if trim( FrmHistory.lbHistory.caption ) <> '' then
     begin
       Edit1.Text:= FrmHistory.lbHistory.caption;
       Edit1.SelStart:= Length( FrmHistory.lbHistory.caption );
     end;
  end;
end;

procedure TForm1.getVersion;
begin
  memo(Version());
end;

procedure TForm1.memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key = 27 then
  begin
     Edit1.SetFocus;
  end;
end;

procedure TForm1.MenuExecute(Sender: TObject);
begin
  Help();
end;

procedure TForm1.NewFolderExecute(Sender: TObject);
begin
  newPageFolder();
end;

procedure TForm1.newPageFolder;
var
   MemoOld: TMemo;
   Pagina: TTabSheet;
   cStri: String;
begin

  if trim( Memo1.Lines.Text ) <> '' then
  begin
     cStrI:= IntToStr(PageControl1.PageCount+1);
     // Aqui criamos nossa aba no PageControl1
     Pagina:= TTabSheet.Create(PageControl1);
     with Pagina do
     begin
         PageControl:=PageControl1;
         Name:= 'Tab'+cStrI;
         MemoOld:= TMemo.create( Pagina );
         MemoOld.Parent:= Pagina;
         MemoOld.Lines.Assign( Memo1.lines );
         MemoOld.Align:= alClient;
         MemoOld.Name:= 'memo' + cStrI;
         Application.ProcessMessages;
         ExecutaComando( 'clear' );
     end;



  end;
end;

procedure TForm1.Help();
var lf: String;
begin
  lf:= #13#10;
     memo(
        'HELP, ' +  lf  +
        'USE /caminho/database.fdb, ' + lf  +
        'CREATE TABLE TABLE_NAME ( ID INTEGER, NAME VARCHAR(64) ),' + lf +
        'ALTER TABLE TABLE_NAME ADD AGE INTEGER,' + lf +
        'DROP TABLE TABLE_NAME,' + lf + 
        'MAXIMIZE, ' + lf +
        'EXIT, ' + lf +
        'QUIT, ' + lf +
        'CLS, ' + lf +
        'DIR, ' + lf +
        'CD, ' + lf +
        'SELECT, ' + lf +
        'DELETE, ' + lf +
        'BROWSER, ' + lf +
        'SHOW TABLES, ' + lf +
        ' '
     );
end;

procedure TForm1.memo( cStr: String );
begin
  Memo1.lines.add( cStr );
end;



end.

