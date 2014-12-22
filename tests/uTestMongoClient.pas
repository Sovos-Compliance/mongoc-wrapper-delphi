unit uTestMongoClient;

interface

uses
  TestFramework,
  uTestMongo, uMongoClient;

type
  TestMongoClient = class(TMongoTestCase)
  published
    procedure Create_UriStringInvalid;
    procedure RunSimpleCommand;
    procedure RunSimpleCommand_Failed;
    procedure GetDatabaseNames;
    procedure MaxBsonSize;
    procedure MaxMessageSize;
    procedure GetReadPrefs;
    procedure GetServerStatus;
    procedure SetReadPrefs;
    procedure GetWriteConcern;
    procedure SetWriteConcern;
  end;

implementation

uses
  MongoBson,
  uMongoReadPrefs, uMongoWriteConcern;

{ TestMongoClient }

procedure TestMongoClient.SetReadPrefs;
var
  prefs: IMongoReadPrefs;
  tags: IBsonBuffer;
  it: IBsonIterator;
begin
  prefs := NewMongoReadPrefs(READ_NEAREST);
  tags := NewBsonBuffer;
  tags.appendStr('test', 'my val');
  prefs.Tags := tags.finish;

  FClient.ReadPrefs := prefs;
  tags := nil;
  prefs := nil;

  Check(FClient.ReadPrefs.Valid);
  Check(READ_NEAREST = FClient.ReadPrefs.Mode);
  it := FClient.ReadPrefs.Tags.find('test');
  CheckEqualsString('my val', it.Value);
end;

procedure TestMongoClient.SetWriteConcern;
var
  wc: IMongoWriteConcern;
begin
  wc := NewMongoWriteConcern;
  wc.Fsync := true;
  wc.Journal := true;
  wc.W := MAJORITY;

  FClient.WriteConcern := wc;
  wc := nil;

  Check(FClient.WriteConcern.Fsync);
  Check(FClient.WriteConcern.Journal);
  Check(FClient.WriteConcern.GetWMajority);
  Check(MAJORITY = FClient.WriteConcern.W);
  CheckEqualsString('', string(FClient.WriteConcern.WTag));
  CheckEquals(0, FClient.WriteConcern.WTimeOut);
end;

procedure TestMongoClient.GetDatabaseNames;
var
  names: TStringArray;
begin
  names := FClient.GetCollectionNames;
  Check(Length(names) > 0);
  CheckEqualsString('admin', string(names[0]));
end;

procedure TestMongoClient.GetServerStatus;
var
  b: IBson;
  it: IBsonIterator;
begin
  b := FClient.GetServerStatus;
  it := b.iterator;

  Check(it.Find('host'));
  Check(it.Find('version'));
  Check(it.Find('process'));
end;

procedure TestMongoClient.GetWriteConcern;
begin
  Check(DEFAULT = FClient.WriteConcern.W);
  Check(not FClient.WriteConcern.Journal);
  Check(not FClient.WriteConcern.Fsync);
  Check(not FClient.WriteConcern.GetWMajority);
  CheckEqualsString('', string(FClient.WriteConcern.WTag));
  CheckEquals(0, FClient.WriteConcern.WTimeOut);
end;

procedure TestMongoClient.MaxBsonSize;
const
  DEFAULT_MAX_BSON_SIZE = 16 * 1024 * 1024;
begin
  CheckEquals(DEFAULT_MAX_BSON_SIZE, FClient.MaxBsonSize);
end;

procedure TestMongoClient.MaxMessageSize;
const
  DEFAULT_MAX_MSG_SIZE = 40 * 1024 * 1024;
begin
  Check(FClient.MaxMessageSize > DEFAULT_MAX_MSG_SIZE);
end;

procedure TestMongoClient.Create_UriStringInvalid;
begin
  try
    TMongoClient.Create('invalid uri string');
    Fail('EMongoClient expected');
  except
    on e: EMongoClient do
      CheckEqualsString('Uri string is invalid', e.Message);
  end;
end;

procedure TestMongoClient.RunSimpleCommand_Failed;
var
  cmd: IBsonBuffer;
begin
  cmd := NewBsonBuffer;
  cmd.append('not existing command', 1);
  try
    FClient.RunCommand(TEST_DB, cmd.finish, nil);
    Fail('EMongoClient expected');
  except
    on e: EMongoClient do
      CheckEqualsString('no such cmd: not existing command', e.Message);
  end;
end;

procedure TestMongoClient.GetReadPrefs;
begin
  Check(READ_PRIMARY = FClient.ReadPrefs.Mode);
  Check(FClient.ReadPrefs.Valid);
  CheckEqualsString('{ }', string(FClient.ReadPrefs.Tags.asJson));
end;

procedure TestMongoClient.RunSimpleCommand;
var
  cmd: IBsonBuffer;
  reply: IBson;
  it: IBsonIterator;
begin
  cmd := NewBsonBuffer;
  cmd.append('isMaster', 1);
  reply := FClient.RunCommand(TEST_DB, cmd.finish, nil);

  it := reply.iterator;
  Check(it.Find('ismaster'));
  Check(it.Find('localTime'));
  Check(it.Find('ok'));
end;

initialization
  RegisterTest(TestMongoClient.Suite);

end.
