unit uMongoClient;

interface

uses
  SysUtils,
  uMongo, uMongoReadPrefs, uMongoWriteConcern, uMongoDatabase, uMongoCollection,
  uMongoGridfs, uMongoCursor,
  MongoBson, uDelphi5;

type

{ TODO:
  mongoc_client_get_uri
  mongoc_client_new_from_uri
  mongoc_client_set_ssl_opts
  mongoc_client_set_stream_initiator

  mongoc_client_pool_set_ssl_opts
}

  EMongoClient = class(EMongo);

  TMongoClient = class(TMongoReadPrefsWriteConcernObject)
  private
    FNativeClient: Pointer;
    FOwnsNativeClient: Boolean;
    function GetMaxBsonSize: Longint;
    function GetMaxMessageSize: Longint;
    constructor Create(ANativeClient: Pointer); overload;
  protected
    function GetReadPrefs: IMongoReadPrefs; override;
    procedure SetReadPrefs(const APrefs: IMongoReadPrefs); override;
    function GetWriteConcern: IMongoWriteConcern; override;
    procedure SetWriteConcern(const AWriteConcern: IMongoWriteConcern); override;
  public
    constructor Create(const uri_string: UTF8String); overload;
    destructor Destroy; override;
    function RunCommand(const ADbName: UTF8String; const ACommand: IBson;
                        const AReadPrefs: IMongoReadPrefs): IBson; overload;
    function RunCommand(const ADbName: UTF8String; const ACommand: IBson;
                        AFields: array of UTF8String;
                        ASkip: LongWord = 0; ALimit: LongWord = 0;
                        ABatchSize: LongWord = 100;
                        AFlags: Integer = MONGOC_QUERY_NONE;
                        const AReadPrefs: IMongoReadPrefs = nil): IMongoCursor; overload;
    function GetDatabaseNames: TStringArray;
    function GetServerStatus(const AReadPrefs: IMongoReadPrefs = nil): IBson;
    function GetDatabase(const name: UTF8String): TMongoDatabase;
    function GetCollection(const DbName, CollectionName: UTF8String): TMongoCollection;
    function GetGridfs(const ADbName: UTF8String;
                       const APrefix: UTF8String = ''): IMongoGridfs;
    property MaxBsonSize: Longint read GetMaxBsonSize;
    property MaxMessageSize: Longint read GetMaxMessageSize;
  end;

  TMongoClientPool = class(TMongoObject)
  private
    FNativePool: Pointer;
  public
    constructor Create(const uri_string: UTF8String);
    destructor Destroy; override;
    procedure Push(var AClient: TMongoClient);
    function Pop: TMongoClient;
    function TryPop: TMongoClient;
  end;

implementation

uses
  uLibMongocAPI, LibBsonAPI;

{ TMongoClient }

constructor TMongoClient.Create(const uri_string: UTF8String);
begin
  FNativeClient := mongoc_client_new(PAnsiChar(uri_string));
  if FNativeClient = nil then
    raise EMongoClient.Create('Uri string is invalid');
  FOwnsNativeClient := true;
end;

constructor TMongoClient.Create(ANativeClient: Pointer);
begin
  FNativeClient := ANativeClient;
  FOwnsNativeClient := false;
end;

destructor TMongoClient.Destroy;
begin
  if FOwnsNativeClient then
    mongoc_client_destroy(FNativeClient);
  inherited;
end;

function TMongoClient.GetDatabaseNames: TStringArray;
var
  names: PPAnsiChar;
begin
  names := mongoc_client_get_database_names(FNativeClient, @FError);
  if names = nil then
    raise EMongoClient.Create(@FError);

  Result := PPAnsiCharToUTF8StringStringArray(names);
  bson_strfreev(names);
end;

function TMongoClient.GetGridfs(const ADbName,
  APrefix: UTF8String): IMongoGridfs;
var
  prefix: PAnsiChar;
  nativeGridfs: Pointer;
begin
  if APrefix <> '' then
    prefix := PAnsiChar(APrefix)
  else
    prefix := nil;

  nativeGridfs := mongoc_client_get_gridfs(FNativeClient, PAnsiChar(ADbName),
                                           prefix, @FError);
  if nativeGridfs = nil then
    raise EMongoClient.Create(@FError);

  Result := NewMongoGridfs(nativeGridfs);
end;

function TMongoClient.GetCollection(const DbName,
  CollectionName: UTF8String): TMongoCollection;
var
  native_coll: Pointer;
begin
  native_coll := mongoc_client_get_collection(FNativeClient, PAnsiChar(DbName),
                                              PAnsiChar(CollectionName));
  Result := TMongoCollection.Create(native_coll);
end;

function TMongoClient.GetDatabase(const name: UTF8String): TMongoDatabase;
begin
  Result := TMongoDatabase.Create(mongoc_client_get_database(FNativeClient, PAnsiChar(name)));
end;

function TMongoClient.GetMaxBsonSize: Longint;
begin
  Result := mongoc_client_get_max_bson_size(FNativeClient);
end;

function TMongoClient.GetMaxMessageSize: Longint;
begin
  Result := mongoc_client_get_max_message_size(FNativeClient);
end;

function TMongoClient.GetReadPrefs: IMongoReadPrefs;
begin
  if FCachedReadPrefs = nil then
    FCachedReadPrefs := NewMongoReadPrefs(mongoc_client_get_read_prefs(FNativeClient), false);
  Result := FCachedReadPrefs;
end;

function TMongoClient.GetServerStatus(const AReadPrefs: IMongoReadPrefs): IBson;
begin
  Result := NewBson;
  if not mongoc_client_get_server_status(FNativeClient, NativeReadPrefsOrNil(AReadPrefs),
                                         Result.NativeBson, @FError) then
    raise EMongoClient.Create(@FError);
end;

function TMongoClient.GetWriteConcern: IMongoWriteConcern;
begin
  if FCachedMongoWriteConcern = nil then
    FCachedMongoWriteConcern := NewMongoWriteConcern(mongoc_client_get_write_concern(FNativeClient), false);
  Result := FCachedMongoWriteConcern;
end;

function TMongoClient.RunCommand(const ADbName: UTF8String; const ACommand: IBson;
  AFields: array of UTF8String; ASkip, ALimit, ABatchSize: LongWord;
  AFlags: Integer; const AReadPrefs: IMongoReadPrefs): IMongoCursor;
var
  fields: IBson;
begin
  Assert(ACommand <> nil);

  fields := ToBson(AFields);

  Result := NewMongoCursor(mongoc_client_command(FNativeClient, PAnsiChar(ADbName),
                           AFlags, ASkip, ALimit, ABatchSize,
                           ACommand.NativeBson,
                           NativeBsonOrNil(fields),
                           NativeReadPrefsOrNil(AReadPrefs)));
end;

function TMongoClient.RunCommand(const ADbName: UTF8String; const ACommand: IBson;
  const AReadPrefs: IMongoReadPrefs): IBson;
begin
  Assert(ACommand <> nil);

  Result := NewBson;
  if not mongoc_client_command_simple(FNativeClient, PAnsiChar(ADbName), ACommand.NativeBson,
                                      NativeReadPrefsOrNil(AReadPrefs), Result.NativeBson,
                                      @FError) then
    raise EMongoClient.Create(@FError);
end;

procedure TMongoClient.SetReadPrefs(const APrefs: IMongoReadPrefs);
begin
  mongoc_client_set_read_prefs(FNativeClient, APrefs.NativeReadPrefs);
end;

procedure TMongoClient.SetWriteConcern(const AWriteConcern: IMongoWriteConcern);
begin
  mongoc_client_set_write_concern(FNativeClient, AWriteConcern.NativeWriteConcern);
end;

{ TMongoClientPool }

constructor TMongoClientPool.Create(const uri_string: UTF8String);
var
  uri: Pointer;
begin
  uri := mongoc_uri_new(PAnsiChar(uri_string));
  if uri = nil then
    raise EMongoClient.Create('Uri string is invalid');

  FNativePool := mongoc_client_pool_new(uri);

  mongoc_uri_destroy(uri);
end;

destructor TMongoClientPool.Destroy;
begin
  if FNativePool <> nil then
    mongoc_client_pool_destroy(FNativePool);
  inherited;
end;

function TMongoClientPool.Pop: TMongoClient;
var
  client: Pointer;
begin
  client := mongoc_client_pool_pop(FNativePool);
  Result := TMongoClient.Create(client);
end;

procedure TMongoClientPool.Push(var AClient: TMongoClient);
begin
  mongoc_client_pool_push(FNativePool, AClient.FNativeClient);
  AClient.Free;
end;

function TMongoClientPool.TryPop: TMongoClient;
var
  client: Pointer;
begin
  client := mongoc_client_pool_try_pop(FNativePool);
  if client = nil then
    Result := nil
  else
    Result := TMongoClient.Create(client);
end;

end.
