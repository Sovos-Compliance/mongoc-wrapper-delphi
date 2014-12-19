program tests_mongoc_wrapper_delphi_xe4;

{$IFDEF DCC_ConsoleTarget}
{$APPTYPE CONSOLE}
{$ENDIF}

{$R *.res}

uses
  System.SysUtils,
  TestMongoBson in 'TestMongoBson.pas',
  TestMongoBsonSerializer in 'TestMongoBsonSerializer.pas',
  LibBsonAPI in '..\src\LibBsonAPI.pas',
  MongoBson in '..\src\MongoBson.pas',
  MongoBsonSerializer in '..\src\MongoBsonSerializer.pas',
  uCnvDictionary in '..\src\uCnvDictionary.pas',
  uDelphi5 in '..\src\uDelphi5.pas',
  MongoTestConsts in 'MongoTestConsts.pas',
  uMain in 'uMain.pas';

begin
  Main;
end.
