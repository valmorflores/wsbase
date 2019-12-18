unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, IBConnection, FileUtil, SynEdit, Forms,
  Controls, Graphics, Dialogs, StdCtrls, DBGrids, ExtCtrls, Buttons, ActnList,
  ComCtrls, uHistory;

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
    procedure newPageFolder;


  private

  public

  end;

var
  Form1: TForm1;
  FrmHistory: TFrmHistory;
  PastaAtual: String;
  HistoricoAtual: Integer;

implementation


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
  Memo1.lines.add( 'dir.folder.files=' + caminho );
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
           Memo1.Lines.Add( Diretorio + F.Name );
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
    Memo1.lines.add( 'dir.folder.folders=' + pasta() );
    if findfirst('*', faDirectory, searchResult) = 0 then
    begin
      repeat
        // Only show directories
        if (searchResult.attr and faDirectory) = faDirectory
        then if searchResult.Name <> '.' then if searchResult.Name <> '..' then
            Memo1.lines.add('Dir = '+searchResult.Name);
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
   Memo1.Lines.add( '->' + pastaAtual );
end;

procedure TForm1.ExecutaComando( cComando: String );
var
    cData, cUser, cHost, cPass: String;
begin
  FrmHistory.Add( cComando );
  if UpperCase( copy( cComando, 1, 3 ) ) = 'CD ' then
  begin
     // Busca arquivos
     Memo1.lines.add( cComando );
     FuncMudaPasta( trim( copy( cComando, 3, 9999 ) ) );
  end;
  if UpperCase( copy( cComando, 1, 3 ) ) = 'DIR' then
  begin
     // Busca arquivos
     Memo1.lines.add( cComando + ' ' + Pasta() );
     FuncDirFolders();
     FuncDir( pastaAtual, false );
  end;
  if UpperCase( copy( cComando, 1, 8 ) ) = 'MAXIMIZE' then
  begin
     // Maximiza tela
     Memo1.lines.add( cComando );
     WindowState:= wsMaximized;
     Application.processMessages;
  end;
  if UpperCase( copy( cComando, 1, 8 ) ) = 'HELP' then
  begin
     // Maximiza tela
     Memo1.lines.add( cComando );
     Help;
  end;
  if UpperCase( copy( cComando, 1, 8 ) ) = 'HISTORY' then
  begin
     GetHistory;
  end;

  if UpperCase( copy( cComando, 1, 5 ) ) = 'CLOSE' then
  begin
     // Maximiza tela
     Memo1.lines.add( cComando );
     SQLQuery1.Close;
  end;

  if UpperCase( copy( cComando, 1, 8 ) ) = 'MAXIMIZE' then
  begin
     // Maximiza tela
     Memo1.lines.add( cComando );
     WindowState:= wsMaximized;
     Application.processMessages;
  end;

  if UpperCase( copy( cComando, 1, 11 ) ) = 'SHOW TABLES' then
  begin
     // Maximiza tela
    Memo1.lines.add( cComando );
    cComando:= 'SELECT rdb$relation_name AS TABELA'+
                '        FROM rdb$relations '+
                '        WHERE rdb$system_flag = 0 '+ //  somente objetos de usuário
                '            and rdb$relation_type = 0 '; //-- somente tabelas;

     SQLQuery1.SQL.clear;
     SQLQuery1.Close;
     SQLQuery1.SQL.Add( cComando );
     try
       SQLQuery1.Open;
       if SQLQuery1.Active then
       begin
         Memo1.lines.add( 'Executando comando ' + cComando );
         while not SQLQuery1.eof do
         begin
            Memo1.lines.add( SQLQuery1.FieldByName( 'TABELA' ).AsString );
            SQLQuery1.next;
         end;
       end;

     except on E: Exception do
        Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
     end;
  end;


  if UpperCase( copy( cComando, 1, 4 ) ) = 'BROW' then // BROWSER
  begin
    // Foco no grid
     Memo1.lines.add( cComando );
     if DBGrid1.CanFocus then
        DBGrid1.SetFocus;
     Edit1.text:= '';
  end;
  if UpperCase( copy( cComando, 1, 3 ) ) = 'CLS' then
  begin
     // Limpar
     Memo1.lines.clear;
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
     cData:= trim( copy( cComando, pos( ' ', cComando )+1, 100 ) );
     if pos( ' ', cData ) > 0 then
        cData:= copy( cData, 0, pos(' ', cData )-1 );
     if pos( ':', cData ) > 0 then
        cHost:= copy( cData, 0, pos(':', cData )-1 );
     if pos( ':', cData ) > 0 then
        cData:= trim( copy( cData, pos(':', cData )+1 ) );
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
     Memo1.lines.add( 'Parametros ' + cUser + '/' + cPass + '@' + cHost + ':' + cData );
     // Conecta ao banco
     if SQLConnector1.ConnectorType = '' then
        SQLConnector1.ConnectorType:='Firebird';     
     SQLConnector1.hostname:= cHost;
     SQLConnector1.username:= cUser;
     SQLConnector1.password:= cPass;
     SQLConnector1.databasename:= cData;
     SQLConnector1.Open;
     Memo1.lines.add( 'Conectado em ' + SQLConnector1.databasename );

  end;
  if UpperCase( copy( cComando, 1, 6 ) ) = 'SELECT' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        Memo1.lines.add( 'Banco desconectado' );
     end
     else
     begin
        SQLQuery1.SQL.clear;
        SQLQuery1.Close;
        SQLQuery1.SQL.Add( cComando );
        try
          SQLQuery1.Open;
          if SQLQuery1.Active then
             Memo1.lines.add( 'Executando comando ' + cComando );

        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'INSERT' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        Memo1.lines.add( 'Banco desconectado' );
     end
     else
     begin
        SQLQuery1.SQL.clear;
        SQLQuery1.Close;
        SQLQuery1.SQL.Add( cComando );
        try
          SQLQuery1.ExecSQL;
          Memo1.lines.add( 'Executando comando ' + cComando );
        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'UPDATE' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        Memo1.lines.add( 'Banco desconectado' );
     end
     else
     begin
        SQLQuery1.SQL.clear;
        SQLQuery1.Close;
        SQLQuery1.SQL.Add( cComando );
        try
          SQLQuery1.ExecSQL;
          Memo1.lines.add( 'Executando comando ' + cComando );
        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
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
        Memo1.lines.add( 'Banco desconectado' );
     end
     else if pos( 'WHERE ', UpperCase( cComando ) ) <= 0 then
     begin
        Memo1.lines.add( 'Você precisa de superpoderes para usar DELETE sem WHERE' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          Memo1.lines.add( 'Executando comando ' + cComando );
        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 5 ) ) = 'ALTER' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        Memo1.lines.add( 'Banco desconectado' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          Memo1.lines.add( 'Executando comando ' + cComando );
        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'CREATE' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        Memo1.lines.add( 'Banco desconectado' );
     end
     else
     begin
        SQLScript1.Script.clear;
        SQLScript1.Script.Add( cComando + ';' + 'COMMIT;' );
        try
          SQLScript1.ExecuteScript;
          Memo1.lines.add( 'Executando comando ' + cComando );
        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;

  if UpperCase( copy( cComando, 1, 6 ) ) = 'COMMIT' then
  begin
     // Conecta ao banco
     if False then //not SQLConnector1..Active then
     begin
        Memo1.lines.add( 'Banco desconectado' );
     end
     else
     begin
        //SQLScript1.Script.clear;
        //SQLScript1.Script.Add( cComando );
        try
          SQLTransaction1.commit;
          Memo1.lines.add( 'Executando comando ' + cComando );
        except on E: Exception do
           Memo1.lines.add( 'Erro: ' + e.message + ' executando ' + cComando );
        end;
     end;
  end;


end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Caption:= 'fpcBase v1.0';
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
         Application.ProcessMessages;
         ExecutaComando( 'clear' );
     end;



  end;
end;

procedure TForm1.Help();
var lf: String;
begin
  lf:= #13#10;
     Memo1.lines.add(
        'HELP, ' +  lf  +
        'USE /caminho/database.fdb, ' + lf  +
        'MAXIMIZE, ' + lf  +
        'EXIT, ' + lf  +
        'QUIT, ' + lf  +
        'CLS, ' + lf  +
        'DIR, ' + lf  +
        'CD, ' + lf  +
        'SELECT, ' + lf  +
        'DELETE, ' + lf  +
        'BROWSER, ' + lf +
        'SHOW TABLES, ' + lf +
        ' '
     );
end;


end.

