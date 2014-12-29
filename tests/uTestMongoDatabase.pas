unit uTestMongoDatabase;

interface

uses
  TestFramework,
  uTestMongo,
  uMongoClient, uMongoDatabase;

type
  TestMongoDatabase = class(TMongoTestCase)
  public
    procedure SetUp; override;
  published
    procedure Drop_InvalidName;
    procedure AddUser;
    procedure Name;
    procedure RunCommand;
    procedure GetCollectionNames;
    procedure HasCollection;
    procedure RemoveUser;
    procedure RemoveAllUsers;
  end;

implementation

uses
  uLibMongocAPI,
  MongoBson;

{ TestMongoDatabase }

procedure TestMongoDatabase.AddUser;
const
  NAME = 'test';
  PASS = '111111';
  EXPECTED_USER = NAME + '@' + TEST_DB;
begin
  mongoc_database_remove_all_users(FDatabase.NativeDatabase, nil);

  FDatabase.AddUser(NAME, PASS, nil, nil);
  try
    FDatabase.AddUser(NAME, PASS, nil, nil);
    Fail('EMongoDatabase expected');
  except
    on e: EMongoDatabase do
      CheckEqualsString('User "' + EXPECTED_USER + '" already exists', e.Message);
  end;
end;

procedure TestMongoDatabase.Drop_InvalidName;
var
  db: TMongoDatabase;
begin
  db := FClient.GetDatabase('*');
  try
    try
      db.Drop;
      Fail('EMongoDatabase expected');
    except
      on e: EMongoDatabase do
        CheckEqualsString('Invalid ns [*.$cmd]', e.Message);
    end;
  finally
    db.Free;
  end;
end;

procedure TestMongoDatabase.GetCollectionNames;
const
  COLL_NAME = 'test';
var
  names: TStringArray;
begin
  CheckEquals(0, Length(FDatabase.GetCollectionNames));

  FDatabase.RunCommand(BSON(['create', COLL_NAME]));
  names := FDatabase.GetCollectionNames;
  CheckEquals(2, Length(names));
  CheckEqualsString(COLL_NAME, string(names[0]));
  CheckEqualsString('system.indexes', string(names[1]));
end;

procedure TestMongoDatabase.HasCollection;
const
  COLL_NAME = 'test';
begin
  Check(not FDatabase.HasCollection(COLL_NAME));

  FDatabase.RunCommand(BSON(['create', COLL_NAME]));
  Check(FDatabase.HasCollection(COLL_NAME));
end;

procedure TestMongoDatabase.Name;
begin
  CheckEqualsString(TEST_DB, string(FDatabase.Name));
end;

procedure TestMongoDatabase.RemoveAllUsers;
var
  it: IBsonIterator;
begin
  FDatabase.AddUser('user1', '123456', nil, nil);
  FDatabase.RemoveAllUsers;
  it := FDatabase.RunCommand(BSON(['usersInfo', 1])).find('users').subiterator;
  CheckFalse(it.next); // users array should be empty
end;

procedure TestMongoDatabase.RemoveUser;
const
  USER_NAME = 'test';
  USER_NAME_IN_ERRMSG = USER_NAME + '@' + TEST_DB;
begin
  FDatabase.AddUser(USER_NAME, '123456', nil, nil);
  FDatabase.RemoveUser(USER_NAME);
  try
    FDatabase.RemoveUser(USER_NAME);
    Fail('EMongoDatabase expected');
  except
    on e: EMongoDatabase do
      CheckEqualsString('User ''' + USER_NAME_IN_ERRMSG + ''' not found', e.Message);
  end;
end;

procedure TestMongoDatabase.RunCommand;
var
  cmd, reply: IBson;
begin
  cmd := BSON(['create', 'test']);

  reply := FDatabase.RunCommand(cmd);
  CheckEqualsString('{ "ok" : 1.000000 }', string(reply.asJson));
  reply := nil;
  try
    reply := FDatabase.RunCommand(cmd);
    Fail('EMongoDatabase expected');
  except
    on e: EMongoDatabase do
      CheckEqualsString('collection already exists', e.Message);
  end;
end;

procedure TestMongoDatabase.SetUp;
begin
  inherited;
  FDatabase.Drop;
  FDatabase.RemoveAllUsers;
end;

initialization
  RegisterTest(TestMongoDatabase.Suite);

end.
