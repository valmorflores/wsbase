unit uconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

  { TFrmConfig }

  TFrmConfig = class(TForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FrmConfig: TFrmConfig;

implementation

{$R *.lfm}

{ TFrmConfig }

procedure TFrmConfig.FormCreate(Sender: TObject);
begin

end;

end.

