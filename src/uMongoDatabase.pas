unit uMongoDatabase;

interface
{ TODO:
  mongoc_database_command
  mongoc_database_create_collection
  mongoc_database_get_collection
}

uses
  LibBsonAPI, MongoBson, uDelphi5,
  uMongo, uMongoReadPrefs, uMongoWriteConcern;

type
  EMongoDatabase = class(EMongo);

  TMongoDatabase = class(TMongoObject)
  private
    FNativeDatabase: Pointer;
    function GetNativeDatabase: Pointer;
    function GetName: UTF8String;
  protected
    function GetReadPrefs: IMongoReadPrefs; override;
    procedure SetReadPrefs(const APrefs: IMongoReadPrefs); override;
    function GetWriteConcern: IMongoWriteConcern; override;
    procedure SetWriteConcern(const AWriteConcern: IMongoWriteConcern); override;
  public
    constructor Create(ANativeDatabase: Pointer);
    destructor Destroy; override;
    procedure AddUser(AUserName, APassword: UTF8String;
                      ARoles, ACustomData: IBson);
    function RunCommand(const ACommand: IBson;
                        const AReadPrefs: IMongoReadPrefs = nil): IBson;
    function GetCollectionNames: TStringArray;
    procedure Drop;
    function HasCollection(const name: UTF8String): Boolean;
    procedure RemoveAllUsers;
    procedure RemoveUser(const name: UTF8String);
    property NativeDatabase: Pointer read GetNativeDatabase;
    property Name: UTF8String read GetName;
  end;

implementation

uses
  uLibMongocAPI;

{ TMongoDatabase }

procedure TMongoDatabase.AddUser(AUserName, APassword: UTF8String; ARoles,
  ACustomData: IBson);
var
  roles, cd: bson_p;
begin
  if ARoles = nil then
    roles := nil
  else
    roles := ARoles.NativeBson;
  if ACustomData = nil then
    cd := nil
  else
    cd := ACustomData.NativeBson;

  if mongoc_database_add_user(FNativeDatabase, PAnsiChar(AUserName),
                              PAnsiChar(APassword), roles, cd, @FError) = 0 then
    raise EMongoDatabase.Create(@FError);
end;

constructor TMongoDatabase.Create(ANativeDatabase: Pointer);
begin
  FNativeDatabase := ANativeDatabase;
end;

destructor TMongoDatabase.Destroy;
begin
  mongoc_database_destroy(FNativeDatabase);
  inherited;
end;

procedure TMongoDatabase.Drop;
begin
  if mongoc_database_drop(FNativeDatabase, @FError) = 0 then
    raise EMongoDatabase.Create(@FError);
end;

function TMongoDatabase.GetCollectionNames: TStringArray;
var
  collections: PPAnsiChar;
begin
  collections := mongoc_database_get_collection_names(FNativeDatabase, @FError);
  if collections = nil then
    raise EMongoDatabase.Create(@FError);

  Result := PPAnsiCharToUTF8StringStringArray(collections);
  bson_strfreev(collections);
end;

function TMongoDatabase.GetName: UTF8String;
begin
  Result := UTF8String(mongoc_database_get_name(FNativeDatabase));
end;

function TMongoDatabase.GetNativeDatabase: Pointer;
begin
  Result := FNativeDatabase;
end;

function TMongoDatabase.GetReadPrefs: IMongoReadPrefs;
begin
  if FCachedReadPrefs = nil then
    FCachedReadPrefs := NewMongoReadPrefs(mongoc_database_get_read_prefs(FNativeDatabase), false);
  Result := FCachedReadPrefs;
end;

function TMongoDatabase.GetWriteConcern: IMongoWriteConcern;
begin
  if FCachedMongoWriteConcern = nil then
    FCachedMongoWriteConcern := NewMongoWriteConcern(mongoc_database_get_write_concern(FNativeDatabase), false);
  Result := FCachedMongoWriteConcern;
end;

function TMongoDatabase.HasCollection(const name: UTF8String): Boolean;
begin
  Result := mongoc_database_has_collection(FNativeDatabase,
                                           PAnsiChar(name), @FError) <> 0;
end;

procedure TMongoDatabase.RemoveAllUsers;
begin
  if mongoc_database_remove_all_users(FNativeDatabase, @FError) = 0 then
    raise EMongoDatabase.Create(@FError);
end;

procedure TMongoDatabase.RemoveUser(const name: UTF8String);
begin
  if mongoc_database_remove_user(FNativeDatabase, PAnsiChar(name), @FError) = 0 then
    raise EMongoDatabase.Create(@FError);
end;

function TMongoDatabase.RunCommand(const ACommand: IBson;
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

  if mongoc_database_command_simple(FNativeDatabase, ACommand.NativeBson,
                                    read_prefs, Result.NativeBson,
                                    @FError) = 0 then
    raise EMongoDatabase.Create(@FError);
end;

procedure TMongoDatabase.SetReadPrefs(const APrefs: IMongoReadPrefs);
begin
  mongoc_database_set_read_prefs(FNativeDatabase, APrefs.NativeReadPrefs);
end;

procedure TMongoDatabase.SetWriteConcern(const AWriteConcern: IMongoWriteConcern);
begin
  mongoc_database_set_write_concern(FNativeDatabase, AWriteConcern.NativeWriteConcern);
end;

end.
