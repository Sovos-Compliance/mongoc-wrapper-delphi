unit uTestMongo;

interface

uses
  TestFramework, uMongoClient, uMongoDatabase, uMongoGridfs, uDelphi5, MongoBson;

const
  DATE_TIME_EPSILON = 1000; // we ignore value less then 1 sec cause unix timestamp
  DOUBLE_EPSILON = 1000;
  // is second-aligned value and mongodb just cut miliseconds
  TEST_DB = 'tets_delphi_wrapper';

type
  TMongoTestCase = class (TTestCase)
  private
    FServerVersion: string;
    function GetServerVersion: string;
    function GetMongoDbV3: Boolean;
  protected
    FClient: TMongoClient;
    FDatabase: TMongoDatabase;
    function StrInArray(const AArr: TStringArray; const AValue: string): Boolean;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    property ServerVersion: string read GetServerVersion;
    property MongoDbV3: Boolean read GetMongoDbV3;
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
  uMongoGridfsFile, SysUtils, Windows, uMongoReadPrefs;

{ TMongoTestCase }

function TMongoTestCase.GetMongoDbV3: Boolean;
begin
  Result := ServerVersion[1] = '3';
end;

function TMongoTestCase.GetServerVersion: string;
var
  b: IBson;
  rp: IMongoReadPrefs;
begin
  if FServerVersion <> '' then
  begin
    Result := FServerVersion;
    Exit;
  end;
  b := FClient.RunCommand(TEST_DB, BSON(['buildinfo', 1]), rp);
  Result := b.find('version').AsUTF8String;
end;

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

function TMongoTestCase.StrInArray(const AArr: TStringArray;
  const AValue: string): Boolean;
var
  i: Integer;
begin
  for i := 0 to Length(AArr) do
    if AValue = AArr[i] then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
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
