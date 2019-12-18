unit uhistory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ValEdit,
  CheckLst, ExtCtrls, StdCtrls;

type

  { TFrmHistory }

  TFrmHistory = class(TForm)
    CheckListBox1: TCheckListBox;
    Edit1: TEdit;
    lbHistory: TLabel;
    Panel1: TPanel;
    procedure CheckListBox1ItemClick(Sender: TObject; Index: integer);
    procedure CheckListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Limpa;

  private

  public
    procedure Add( cStr: String );
  end;

var
  FrmHistory: TFrmHistory;

implementation

{$R *.lfm}

{ TFrmHistory }

procedure TFrmHistory.FormCreate(Sender: TObject);
begin
    if FileExists( ExtractFilePath( Application.ExeName ) +  'history.sys' ) then
    begin
       CheckListBox1.Items.LoadFromFile( ExtractFilePath( Application.ExeName ) +  'history.sys' );
    end;
end;

procedure TFrmHistory.FormShow(Sender: TObject);
var
  i: integer;
begin
  for i:= 0 to CheckListBox1.Items.count-1 do
  begin
     ChecklistBox1.Checked[i]:= false;
  end;
end;

procedure TFrmHistory.CheckListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i: Integer;
begin
  lbHistory.caption:= '';
  if Key = 13 then
  begin
     if CheckListBox1.SelCount > 0 then
     begin
        for i:= 0 to CheckListBox1.Items.count-1 do
        begin
           if CheckListBox1.Selected[i] then
              lbHistory.caption:= CheckListBox1.Items[i];
        end;
     end;
     ModalResult:= mrOk;
  end
  else if Key = 10 then
     ModalResult:= mrOk
  else if Key = 27 then
     ModalResult:= mrCancel;
end;

procedure TFrmHistory.CheckListBox1SelectionChange(Sender: TObject;
  User: boolean);
var
  i: integer;
begin
  for i:= 0 to CheckListBox1.Items.count-1 do
  begin
     if CheckListBox1.Checked[i] then
        lbHistory.caption:= CheckListBox1.Items[i];
  end;
end;

procedure TFrmHistory.CheckListBox1ItemClick(Sender: TObject; Index: integer);
begin

end;

procedure TFrmHistory.Limpa;
begin
  CheckListBox1.Items.Clear;
  CheckListBox1.Items.SaveToFile( ExtractFilePath( Application.ExeName ) +  'history.sys' );
end;

procedure TFrmHistory.Add( cStr: String );
var
   lMore: Boolean;
begin
   lMore:= False;
   if CheckListBox1.Items.count >0 then
   begin
      lMore:= True;
   end;
   if not lMore then
      CheckListBox1.Items.Insert( 0, cStr )
   else if ( trim( CheckListBox1.Items[0] ) <> trim( cStr ) ) then
      CheckListBox1.Items.Insert( 0, cStr );
   CheckListBox1.Items.SaveToFile( ExtractFilePath( Application.ExeName ) +  'history.sys' );
end;

end.

