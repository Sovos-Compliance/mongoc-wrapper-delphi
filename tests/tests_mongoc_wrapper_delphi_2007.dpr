program tests_mongoc_wrapper_delphi_2007;

{$IFDEF DCC_ConsoleTarget}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  SysUtils,
  TestMongoBson in 'TestMongoBson.pas',
  TestMongoBsonSerializer in 'TestMongoBsonSerializer.pas',
  uMain in 'uMain.pas',
  uTestMongo in 'uTestMongo.pas',
  uTestMongoClient in 'uTestMongoClient.pas',
  uTestMongoCollection in 'uTestMongoCollection.pas',
  uTestMongoDatabase in 'uTestMongoDatabase.pas',
  LibBsonAPI in '..\src\LibBsonAPI.pas',
  MongoBson in '..\src\MongoBson.pas',
  MongoBsonSerializer in '..\src\MongoBsonSerializer.pas',
  uCnvDictionary in '..\src\uCnvDictionary.pas',
  uDelphi5 in '..\src\uDelphi5.pas',
  uLibMongocAPI in '..\src\uLibMongocAPI.pas',
  uMongo in '..\src\uMongo.pas',
  uMongoClient in '..\src\uMongoClient.pas',
  uMongoCollection in '..\src\uMongoCollection.pas',
  uMongoDatabase in '..\src\uMongoDatabase.pas',
  uMongoReadPrefs in '..\src\uMongoReadPrefs.pas',
  uMongoWriteConcern in '..\src\uMongoWriteConcern.pas';

begin
  Main;
end.
