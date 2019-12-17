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
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
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

procedure TFrmHistory.Add( cStr: String );
begin
    CheckListBox1.Items.Insert( 0, cStr );
    CheckListBox1.Items.SaveToFile( ExtractFilePath( Application.ExeName ) +  'history.sys' );
end;

end.

