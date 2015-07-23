unit uMain;
(* This unit needed to avoid copypast between Delphi XE4 Delphi 2007 and Delphi 5 *)

interface

procedure Main;

implementation

uses
  SysUtils,
  Forms,
  {$IFDEF OnDemandLibbsonLoad}
  LibBsonAPI,
  {$ENDIF}
  {$IFDEF OnDemandMongocLoad}
  uLibMongocAPI,
  {$ENDIF}
  TestFramework,
  {$IFDEF VER130}
  GUITestRunner_Legacy,
  {$ELSE}
  GUITestRunner,
  {$ENDIF}
  XmlTestRunner2;

var
  xml_filename: string;

procedure Main;
begin
  if IsConsole then
  begin
    xml_filename := ChangeFileExt(ExtractFileName(Application.ExeName), '.xml');
    XMLTestRunner2.RunRegisteredTests(xml_filename);
  end
  else
    {$IFDEF VER130}
    GUITestRunner_Legacy.RunRegisteredTests;
    {$ELSE}
    GUITestRunner.RunRegisteredTests;
    {$ENDIF}
end;

initialization
{$IFDEF OnDemandLibbsonLoad}
  if (ParamCount > 0) and (LowerCase(ExtractFileExt(ParamStr(1))) = '.dll') then
    LoadLibbsonLibrary(ParamStr(1))
  else
    LoadLibbsonLibrary;
{$ENDIF}
{$IFDEF OnDemandMongocLoad}
  if (ParamCount > 1) and (LowerCase(ExtractFileExt(ParamStr(2))) = '.dll') then
    LoadLibmongocLibrary(ParamStr(2))
  else
    LoadLibmongocLibrary;
{$ENDIF}

finalization
  // we don't call FreeLibmongocLibrary or FreeLibbsonLibrary
  // cause they are released automatically
  // and issues with finalization order can cause access violations

end.
