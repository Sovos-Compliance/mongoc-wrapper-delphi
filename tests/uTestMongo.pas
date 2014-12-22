unit uTestMongo;

interface

uses
  TestFramework, uMongoClient;

const
  DATE_TIME_EPSILON = 1000; // we ignore value less then 1 sec cause unix timestamp
  // is second-aligned value and mongodb just cut miliseconds
  TEST_DB = 'tets_delphi_wrapper';

type
  TMongoTestCase = class (TTestCase)
  protected
    FClient: TMongoClient;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  end;

implementation

{ TMongoTestCase }

procedure TMongoTestCase.SetUp;
begin
  inherited;
  FClient := TMongoClient.Create('mongodb://127.0.0.1:27017/' + TEST_DB);
end;

procedure TMongoTestCase.TearDown;
begin
  inherited;
  FClient.Free;
end;

end.
