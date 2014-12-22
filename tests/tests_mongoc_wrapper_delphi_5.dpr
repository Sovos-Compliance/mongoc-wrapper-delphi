program tests_mongoc_wrapper_delphi_5;

uses
  Forms,
  LibBsonAPI in '..\src\LibBsonAPI.pas',
  MongoBson in '..\src\MongoBson.pas',
  MongoBsonSerializer in '..\src\MongoBsonSerializer.pas',
  uCnvDictionary in '..\src\uCnvDictionary.pas',
  uDelphi5 in '..\src\uDelphi5.pas',
  MongoTestConsts in 'MongoTestConsts.pas',
  TestMongoBson in 'TestMongoBson.pas',
  TestMongoBsonSerializer in 'TestMongoBsonSerializer.pas',
  uMain in 'uMain.pas';

{$R *.RES}

begin
  Main;
end.
