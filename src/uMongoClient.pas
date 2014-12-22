unit uMongoClient;

interface

uses
  SysUtils,
  uMongo, uMongoReadPrefs, uMongoWriteConcern,
  MongoBson, LibBsonAPI;

type

{ TODO:
  mongoc_client_get_collection
  mongoc_client_get_database
  mongoc_client_get_gridfs
  mongoc_client_get_uri
  mongoc_client_new_from_uri
  mongoc_client_set_ssl_opts
  mongoc_client_set_stream_initiator
}

  EMongoClient = class(EMongo);

  TMongoClient = class
  private
    FNativeClient: Pointer;
    FError: bson_error_t;
    FCachedReadPrefs: IMongoReadPrefs;
    FCachedMongoWriteConcern: IMongoWriteConcern;
    function GetMaxBsonSize: Longint;
    function GetMaxMessageSize: Longint;
    function GetReadPrefs: IMongoReadPrefs;
    procedure SetReadPrefs(const APrefs: IMongoReadPrefs);
    function GetWriteConcern: IMongoWriteConcern;
    procedure SetWriteConcern(const AWriteConcern: IMongoWriteConcern);
  public
    constructor Create(const uri_string: UTF8String);
    destructor Destroy; override;
    function RunCommand(const ADbName: UTF8String; const ACommand: IBson;
                        const AReadPrefs: IMongoReadPrefs): IBson;
    function GetCollectionNames: TStringArray;
    function GetServerStatus: IBson;
    property MaxBsonSize: Longint read GetMaxBsonSize;
    property MaxMessageSize: Longint read GetMaxMessageSize;
    property ReadPrefs: IMongoReadPrefs read GetReadPrefs write SetReadPrefs;
    property WriteConcern: IMongoWriteConcern read GetWriteConcern write SetWriteConcern;
  end;

implementation

uses
  uLibMongocAPI;

{ TMongoClient }

constructor TMongoClient.Create(const uri_string: UTF8String);
begin
  FCachedReadPrefs := nil;
  FCachedMongoWriteConcern := nil;
  FNativeClient := mongoc_client_new(PAnsiChar(uri_string));
  if FNativeClient = nil then
    raise EMongoClient.Create('Uri string is invalid');
end;

destructor TMongoClient.Destroy;
begin
  mongoc_client_destroy(FNativeClient);
  inherited;
end;

function TMongoClient.GetCollectionNames: TStringArray;
var
  names: PPAnsiChar;
  name: PAnsiChar;
  i: Integer;
begin
  names := mongoc_client_get_database_names(FNativeClient, @FError);
  if names = nil then
    raise EMongoClient.Create(@FError);

  i := 0;
  name := names^;
  while name <> nil do
  begin
    SetLength(Result, i + 1);
    Result[i] := UTF8String(name);
    Inc(i);
    name := PPAnsiChar(NativeInt(names) + i * SizeOf(PAnsiChar))^;
  end;
  bson_strfreev(names);
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

function TMongoClient.GetServerStatus: IBson;
begin
  Result := NewBson(bson_new, true);
  if mongoc_client_get_server_status(FNativeClient, nil, Result.NativeBson, @FError) = 0 then
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
var
  read_prefs: Pointer;
begin
  Assert(ACommand <> nil);

  if AReadPrefs <> nil then
    read_prefs := AReadPrefs.NativeReadPrefs
  else
    read_prefs := nil;
  Result := NewBson(bson_new, true);

  if mongoc_client_command_simple(FNativeClient, PAnsiChar(ADbName), ACommand.NativeBson,
                                  read_prefs, Result.NativeBson, @FError) = 0 then
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
