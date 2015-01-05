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
  uMain in 'uMain.pas',
  uLibMongocAPI in '..\src\uLibMongocAPI.pas',
  uMongoClient in '..\src\uMongoClient.pas',
  uMongoReadPrefs in '..\src\uMongoReadPrefs.pas',
  uTestMongoClient in 'uTestMongoClient.pas',
  uMongoWriteConcern in '..\src\uMongoWriteConcern.pas',
  uMongo in '..\src\uMongo.pas',
  uTestMongo in 'uTestMongo.pas',
  uMongoDatabase in '..\src\uMongoDatabase.pas',
  uTestMongoDatabase in 'uTestMongoDatabase.pas',
  uMongoCollection in '..\src\uMongoCollection.pas',
  uTestMongoCollection in 'uTestMongoCollection.pas',
  uMongoCursor in '..\src\uMongoCursor.pas',
  uTestMongoCursor in 'uTestMongoCursor.pas';

begin
  Main;
end.
