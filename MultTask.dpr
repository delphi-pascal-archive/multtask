program MultTask;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain};

{$R *.RES}

begin
  Application.Title:='������� ����������� ���������';
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
