program xbcontrol;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, setunit
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='XBControl v0.5';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.ShowMainForm := False; //Скрываем MainForm
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSetForm, SetForm);
  Application.Run;
end.

