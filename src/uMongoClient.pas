unit uMongoClient;

interface

uses
  SysUtils,
  uMongo, uMongoReadPrefs, uMongoWriteConcern, uMongoDatabase, uMongoCollection,
  uMongoGridfs,
  MongoBson, uDelphi5;

type

{ TODO:
  mongoc_client_get_uri
  mongoc_client_new_from_uri
  mongoc_client_set_ssl_opts
  mongoc_client_set_stream_initiator
}

  EMongoClient = class(EMongo);

  TMongoClient = class(TMongoReadPrefsWriteConcernObject)
  private
    FNativeClient: Pointer;
    function GetMaxBsonSize: Longint;
    function GetMaxMessageSize: Longint;
  protected
    function GetReadPrefs: IMongoReadPrefs; override;
    procedure SetReadPrefs(const APrefs: IMongoReadPrefs); override;
    function GetWriteConcern: IMongoWriteConcern; override;
    procedure SetWriteConcern(const AWriteConcern: IMongoWriteConcern); override;
  public
    constructor Create(const uri_string: UTF8String);
    destructor Destroy; override;
    function RunCommand(const ADbName: UTF8String; const ACommand: IBson;
                        const AReadPrefs: IMongoReadPrefs): IBson;
    function GetDatabaseNames: TStringArray;
    function GetServerStatus(const AReadPrefs: IMongoReadPrefs = nil): IBson;
    function GetDatabase(const name: UTF8String): TMongoDatabase;
    function GetCollection(const DbName, CollectionName: UTF8String): TMongoCollection;
    function GetGridfs(const ADbName: UTF8String;
                       const APrefix: UTF8String = ''): IMongoGridfs;
    property MaxBsonSize: Longint read GetMaxBsonSize;
    property MaxMessageSize: Longint read GetMaxMessageSize;
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
end;

destructor TMongoClient.Destroy;
begin
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

end.
