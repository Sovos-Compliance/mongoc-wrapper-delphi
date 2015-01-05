program tests_mongoc_wrapper_delphi_5;

{$IFDEF DCC_ConsoleTarget}
{$APPTYPE CONSOLE}
{$ENDIF}

{$R *.RES}

uses
  Forms,
  LibBsonAPI in '..\src\LibBsonAPI.pas',
  MongoBson in '..\src\MongoBson.pas',
  MongoBsonSerializer in '..\src\MongoBsonSerializer.pas',
  uCnvDictionary in '..\src\uCnvDictionary.pas',
  uDelphi5 in '..\src\uDelphi5.pas',
  TestMongoBson in 'TestMongoBson.pas',
  TestMongoBsonSerializer in 'TestMongoBsonSerializer.pas',
  uMain in 'uMain.pas',
  uMongoDatabase in '..\src\uMongoDatabase.pas',
  uTestMongoDatabase in 'uTestMongoDatabase.pas',
  uTestMongo in 'uTestMongo.pas',
  uLibMongocAPI in '..\src\uLibMongocAPI.pas',
  uMongo in '..\src\uMongo.pas',
  uMongoClient in '..\src\uMongoClient.pas',
  uMongoReadPrefs in '..\src\uMongoReadPrefs.pas',
  uMongoWriteConcern in '..\src\uMongoWriteConcern.pas',
  uTestMongoClient in 'uTestMongoClient.pas',
  uMongoCollection in '..\src\uMongoCollection.pas',
  uTestMongoCollection in 'uTestMongoCollection.pas',
  uMongoCursor in '..\src\uMongoCursor.pas',
  uTestMongoCursor in 'uTestMongoCursor.pas',
  uMongoGridfs in '..\src\uMongoGridfs.pas',
  uMongoGridfsFile in '..\src\uMongoGridfsFile.pas',
  uTestMongoGridfs in 'uTestMongoGridfs.pas',
  uTestMongoGridfsFile in 'uTestMongoGridfsFile.pas';

begin
  Main;
end.
