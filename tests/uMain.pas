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
  TestFramework,
  GUITestRunner,
  XmlTestRunner2;

var
  xml_filename: string;

procedure Main;
begin
{$IFDEF OnDemandLibbsonLoad}
  if LowerCase(ExtractFileExt(ParamStr(1))) = '.dll' then
    LoadLibbsonLibrary(ParamStr(1))
  else
    LoadLibbsonLibrary;
{$ENDIF}

  if IsConsole then
  begin
    xml_filename := ChangeFileExt(ExtractFileName(Application.ExeName), '.xml');
    XMLTestRunner2.RunRegisteredTests(xml_filename);
  end
  else
    GUITestRunner.RunRegisteredTests;
{$IFDEF OnDemandLibbsonLoad}
  FreeLibbsonLibrary;
{$ENDIF}
end;

end.
