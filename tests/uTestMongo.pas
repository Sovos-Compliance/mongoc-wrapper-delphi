unit uTestMongo;

interface

uses
  TestFramework, uMongoClient, uMongoDatabase, uMongoGridfs, uDelphi5;

const
  DATE_TIME_EPSILON = 1000; // we ignore value less then 1 sec cause unix timestamp
  DOUBLE_EPSILON = 1000;
  // is second-aligned value and mongodb just cut miliseconds
  TEST_DB = 'tets_delphi_wrapper';

type
  TMongoTestCase = class (TTestCase)
  protected
    FClient: TMongoClient;
    FDatabase: TMongoDatabase;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    class function NowUTC: TDateTime;
  end;

  TMongoGridfsTestCase = class(TMongoTestCase)
  protected
    FGridfs: IMongoGridfs;
    procedure CreateFileStub(const AName: UTF8String; const AData: UTF8String = '');
  public
    procedure SetUp; override;
  end;

implementation

uses
  uMongoGridfsFile, SysUtils, Windows;

{ TMongoTestCase }

class function TMongoTestCase.NowUTC: TDateTime;
var
  sys: TSystemTime;
begin
  GetSystemTime(sys);
  Result := SystemTimeToDateTime(sys);
end;

procedure TMongoTestCase.SetUp;
begin
  inherited;
  FClient := TMongoClient.Create('mongodb://127.0.0.1:27017/' + TEST_DB);
  FDatabase := FClient.GetDatabase(TEST_DB);
end;

procedure TMongoTestCase.TearDown;
begin
  FDatabase.Free;
  FClient.Free;
  inherited;
end;

{ TMongoGridfsTestCase }

procedure TMongoGridfsTestCase.CreateFileStub(const AName: UTF8String;
  const AData: UTF8String);
var
  f: IMongoGridfsFile;
begin
  f := FGridfs.CreateFile(AName);
  if AData <> '' then
    CheckEquals(Length(AData), f.Write(AData[1], Length(AData)));
  f.Save;
end;

procedure TMongoGridfsTestCase.SetUp;
begin
  inherited;
  FGridfs := FClient.GetGridfs(TEST_DB, 'test_gfs');
  try
    FGridfs.Drop;
  except
    // just ensure it's clean
  end;
end;

end.
