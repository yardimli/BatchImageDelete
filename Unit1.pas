unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvXPCore, JvXPButtons, StdCtrls, JvExStdCtrls, JvMemo;

type
  TForm1 = class(TForm)
    JvMemo1: TJvMemo;
    JvXPButton3: TJvXPButton;
    procedure JvXPButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.JvXPButton3Click(Sender: TObject);
begin
 CLOSE;
end;

end.
