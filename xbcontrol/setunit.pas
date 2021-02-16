unit setunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, XMLPropStorage, Buttons, Process, LCLTranslator, DefaultTranslator;

type

  { TMainForm }

  { TSetForm }

  TSetForm = class(TForm)
    Bevel1: TBevel;
    CTempBox: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ResetBtn: TSpeedButton;
    CloseBtn: TSpeedButton;
    AutoStartBtn: TSpeedButton;
    BrightnessBar: TTrackBar;
    RBar: TTrackBar;
    GBar: TTrackBar;
    BBar: TTrackBar;
    TrayIcon1: TTrayIcon;
    XMLPropStorage1: TXMLPropStorage;
    procedure AutoStartBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure CTempBoxChange(Sender: TObject);
    procedure CTempBoxKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RBarClick(Sender: TObject);
    procedure SetBrightness;
    procedure ResetBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure AutoStartBtnClick(Sender: TObject);
    procedure BrightnessBarChange(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
  private

  public
  var
    Display: string;

  end;

var
  SetForm: TSetForm;

resourcestring
  SNotScreen = 'The current screen is not found! Application terminate!';

implementation

uses unit1;

{$R *.lfm}

{ TSetForm }


//Определение дисплея
function SetDisplay: string;
var
  D: TStringList;
  ExProcess: TProcess;
begin
  D := TStringList.Create;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Options := ExProcess.Options + [poUsePipes, poWaitOnExit];

    ExProcess.Parameters.Add('echo $(xrandr -q | grep ' + '''' +
      ' connected' + '''' + ' | head -n 1 | cut -d ' + '''' + ' ' + '''' + ' -f1)');
    ExProcess.Execute;

    D.LoadFromStream(ExProcess.Output);

    if D.Count > 0 then
      Result := D[0]
    else
      Result := '';

  finally
    D.Free;
    ExProcess.Free;
  end;
end;

//Вычисление гаммы
function SetGamma: string;
begin
  Result := FloatToStr(SetForm.RBar.Position / 100) + ':';
  Result := Result + FloatToStr(SetForm.GBar.Position / 100) + ':';
  Result := Result + FloatToStr(SetForm.BBar.Position / 100);
end;

//Изменение яркости
procedure TSetForm.SetBrightness;
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');

    ExProcess.Parameters.Add('xrandr --output ' + Display + ' --brightness ' +
      FloatToStr(BrightnessBar.Position / 100) + ' --gamma ' + SetGamma);

    ExProcess.Options := ExProcess.Options + [poWaitOnExit];
    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

procedure TSetForm.ResetBtnClick(Sender: TObject);
begin
  BrightnessBar.Position := BrightnessBar.Max;
  RBar.Position := RBar.Max;
  GBar.Position := GBar.Max;
  BBar.Position := BBar.Max;
  CTempBox.ItemIndex := 0;
end;

procedure TSetForm.CloseBtnClick(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TSetForm.AutoStartBtnClick(Sender: TObject);
begin
  if AutoStartBtn.Down = True then
    AutoStartBtn.AllowAllUp := True
  else
    AutoStartBtn.Down := False;
end;

procedure TSetForm.FormCreate(Sender: TObject);
begin
  //Ищем текущий экран
  Display := SetDisplay;

  if Display = '' then
  begin
    MessageDlg(SNotScreen, mtWarning, [mbOK], 0);
    Application.Terminate;
  end;

  SetForm.Caption := Application.Title + ' [Screen: ' + Display + ']';

  TrayIcon1.Icon := Application.Icon;
  TrayIcon1.Hint := Application.Title;

  SetForm.XMLPropStorage1.FileName :=
    GetEnvironmentVariable('HOME') + '/.config/xbcontrol.xml';
end;

procedure TSetForm.FormShow(Sender: TObject);
begin
  if FileExists(GetEnvironmentVariable('HOME') +
    '/.config/autostart/xbcontrol.desktop') then
    AutoStartBtn.Down := True
  else
    AutoStartBtn.Down := False;
end;

procedure TSetForm.RBarClick(Sender: TObject);
begin
  CTempBox.ItemIndex := 0;
end;

procedure TSetForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  XMLPropStorage1.Save;
end;

procedure TSetForm.AutoStartBtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if not DirectoryExists(GetEnvironmentVariable('HOME') + '/.config/autostart') then
    mkDir(GetEnvironmentVariable('HOME') + '/.config/autostart')
  else

  if (FileExists(GetEnvironmentVariable('HOME') +
    '/.config/autostart/xbcontrol.desktop')) and (AutoStartBtn.Down = False) then
    DeleteFile(GetEnvironmentVariable('HOME') + '/.config/autostart/xbcontrol.desktop')
  else
    CopyFile('/usr/share/applications/xbcontrol.desktop',
      GetEnvironmentVariable('HOME') + '/.config/autostart/xbcontrol.desktop', False);
end;

//Color Temperature
procedure TSetForm.CTempBoxChange(Sender: TObject);
begin
  case CTempBox.ItemIndex of
    0: //...
      ResetBtn.Click;
    1: //2500K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 64;
      BBar.Position := 28;
    end;
    2: //3000K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 72;
      BBar.Position := 43;
    end;
    3: //3500K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 78;
      BBar.Position := 55;
    end;
    4: //4000K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 83;
      BBar.Position := 65;
    end;
    5: //4500K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 87;
      BBar.Position := 74;
    end;
    6: //5000K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 90;
      BBar.Position := 81;
    end;
    7: //5500K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 94;
      BBar.Position := 88;
    end;
    8: //6000K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := 97;
      BBar.Position := 94;
    end;
    9: //6500K
    begin
      RBar.Position := RBar.Max;
      GBar.Position := GBar.Max;
      BBar.Position := BBar.Max;
    end;
    10: //7000K
    begin
      RBar.Position := 95;
      GBar.Position := 96;
      BBar.Position := BBar.Max;
    end;
    11: //7500K
    begin
      RBar.Position := 91;
      GBar.Position := 94;
      BBar.Position := BBar.Max;
    end;
    12: //8000K
    begin
      RBar.Position := 88;
      GBar.Position := 92;
      BBar.Position := BBar.Max;
    end;
    13: //8500K
    begin
      RBar.Position := 85;
      GBar.Position := 90;
      BBar.Position := BBar.Max;
    end;
    14: //9000K
    begin
      RBar.Position := 83;
      GBar.Position := 89;
      BBar.Position := BBar.Max;
    end;
    15: //9500K
    begin
      RBar.Position := 80;
      GBar.Position := 87;
      BBar.Position := BBar.Max;
    end;
    16: //10000K
    begin
      RBar.Position := 78;
      GBar.Position := 86;
      BBar.Position := BBar.Max;
    end;
  end;
end;

procedure TSetForm.CTempBoxKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  Key := 0;
  Exit;
end;

procedure TSetForm.BrightnessBarChange(Sender: TObject);
begin
  //Установка яркости и гаммы
  SetBrightness;
end;

procedure TSetForm.TrayIcon1Click(Sender: TObject);
begin
  if SetForm.Visible then
    SetForm.Close
  else
    SetForm.Show;
end;

end.
