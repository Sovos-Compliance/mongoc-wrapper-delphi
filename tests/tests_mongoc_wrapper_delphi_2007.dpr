program tests_mongoc_wrapper_delphi_2007;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  MongoTestConsts in 'MongoTestConsts.pas',
  TestMongoBson in 'TestMongoBson.pas',
  TestMongoBsonSerializer in 'TestMongoBsonSerializer.pas',
  uMain in 'uMain.pas',
  LibBsonAPI in '..\src\LibBsonAPI.pas',
  MongoBson in '..\src\MongoBson.pas',
  MongoBsonSerializer in '..\src\MongoBsonSerializer.pas',
  uCnvDictionary in '..\src\uCnvDictionary.pas',
  uDelphi5 in '..\src\uDelphi5.pas';

begin
  Main;
end.
