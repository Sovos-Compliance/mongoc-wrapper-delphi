unit uMongoCollection;

interface

{ TODO:
  mongoc_collection_aggregate
  mongoc_collection_command
  mongoc_collection_create_bulk_operation
  mongoc_collection_find
  mongoc_collection_get_last_error
  mongoc_collection_keys_to_index_string
  mongoc_collection_validate
}

uses
  uMongo, MongoBson, uMongoReadPrefs, uMongoWriteConcern, uDelphi5;

const
  MONGOC_QUERY_NONE              = 0;
  MONGOC_QUERY_TAILABLE_CURSOR   = 2;
  MONGOC_QUERY_SLAVE_OK          = 4;
  MONGOC_QUERY_OPLOG_REPLAY      = 8;
  MONGOC_QUERY_NO_CURSOR_TIMEOUT = 16;
  MONGOC_QUERY_AWAIT_DATA        = 32;
  MONGOC_QUERY_EXHAUST           = 64;
  MONGOC_QUERY_PARTIAL           = 128;

  MONGOC_INSERT_NONE              = 0;
  MONGOC_INSERT_CONTINUE_ON_ERROR = 1;

  MONGOC_REMOVE_NONE          = 0;
  MONGOC_REMOVE_SINGLE_REMOVE = 1;

  MONGOC_UPDATE_NONE         = 0;
  MONGOC_UPDATE_UPSERT       = 1;
  MONGOC_UPDATE_MULTI_UPDATE = 2;

type
  EMongoCollection = class(EMongo);

  TMongoCollection = class(TMongoObject)
  private
    FNativeCollection: Pointer;
    function GetName: UTF8String;
    function FindAndModify(const AQuery, AUpdate: IBson;
                           ARemove, AUpsert, ANew: Boolean;
                           const ASort, AFields: array of UTF8String): IBson; overload;
  protected
    function GetReadPrefs: IMongoReadPrefs; override;
    procedure SetReadPrefs(const APrefs: IMongoReadPrefs); override;
    function GetWriteConcern: IMongoWriteConcern; override;
    procedure SetWriteConcern(const AWriteConcern: IMongoWriteConcern); override;
  public
    constructor Create(ANativeCollection: Pointer);
    destructor Destroy; override;
    function RunCommand(const ACommand: IBson;
                        const AReadPrefs: IMongoReadPrefs = nil): IBson;
    function GetCount(const AQuery: IBson = nil;
                      ASkip: Int64 = 0; ALimit: Int64 = 0;
                      AReadPrefs: IMongoReadPrefs = nil;
                      AFlags: Integer = MONGOC_QUERY_NONE): Int64;
    procedure CreateIndex(const AKeys: array of UTF8String;
                          const AName: UTF8String = '';
                          AUniq: Boolean = false;
                          ADropDups: Boolean = false;
                          ABackground: Boolean = false;
                          ASparse: Boolean = false;
                          AExpireAfterSeconds: LongInt = -1);
    procedure DropIndex(const AName: UTF8String);
    procedure Drop;
    function FindAndModify(const AQuery, AUpdate: IBson;
                           ASort, AFields: array of UTF8String;
                           AUpsert: Boolean = false;
                           ANew: Boolean = false): IBson; overload;
    function FindAndModify(const AQuery, AUpdate: IBson;
                           AUpsert: Boolean = false;
                           ANew: Boolean = false): IBson; overload;
    function FindAndModifyRemove(const AQuery: IBson;
                                 ASort, AFields: array of UTF8String): IBson; overload;
    function FindAndModifyRemove(const AQuery: IBson): IBson; overload;
    procedure Insert(const ADcoument: IBson;
                     const AWriteConcern: IMongoWriteConcern = nil;
                     AFlags: Integer = MONGOC_INSERT_NONE);
    procedure Remove(const ASelector: IBson;
                     const AWriteConcern: IMongoWriteConcern = nil;
                     AFlags: Integer = MONGOC_REMOVE_NONE);
    procedure Rename(const ANewCollectionName: UTF8String); overload;
    procedure Rename(const ANewDbName, ANewCollectionName: UTF8String;
                     ADropTargerBeforeRename: Boolean); overload;
    procedure Save(const ADocument: IBson;
                   const AWriteConcern: IMongoWriteConcern = nil);
    function GetStats: IBson;
    procedure Update(const ASelector, AUpdate: IBson;
                     const AWriteConcern: IMongoWriteConcern = nil;
                     AFlags: Integer = MONGOC_UPDATE_NONE);
    property Name: UTF8String read GetName;
  end;

implementation

uses
  uLibMongocAPI;

{ TMongoCollection }

constructor TMongoCollection.Create(ANativeCollection: Pointer);
begin
  FNativeCollection := ANativeCollection;
end;

procedure TMongoCollection.CreateIndex(const AKeys: array of UTF8String;
  const AName: UTF8String; AUniq, ADropDups, ABackground, ASparse: Boolean;
  AExpireAfterSeconds: Integer);
var
  opt: mongoc_index_opt_t;
  bkeys: IBsonBuffer;
  i: Integer;
begin
  bkeys := NewBsonBuffer;
  for i := Low(AKeys) to High(AKeys) do
    bkeys.append(Akeys[i], 1);

  mongoc_index_opt_init(@opt);
  with opt do
  begin
    if AName <> '' then
      name := PAnsiChar(AName);
    unique := AUniq;
    drop_dups := ADropDups;
    background := ABackground;
    sparse := ASparse;
    expire_after_seconds := AExpireAfterSeconds;
  end;

  if not mongoc_collection_create_index(FNativeCollection, bkeys.finish.NativeBson,
                                        @opt, @FError) then
    raise EMongoCollection.Create(@FError);
end;

destructor TMongoCollection.Destroy;
begin
  mongoc_collection_destroy(FNativeCollection);
end;

procedure TMongoCollection.Drop;
begin
  if not mongoc_collection_drop(FNativeCollection, @FError) then
    raise EMongoCollection.Create(@FError);
end;

procedure TMongoCollection.DropIndex(const AName: UTF8String);
begin
  if not mongoc_collection_drop_index(FNativeCollection, PAnsiChar(AName),
                                      @FError) then
    raise EMongoCollection.Create(@FError);
end;

function TMongoCollection.FindAndModify(const AQuery, AUpdate: IBson; ASort,
  AFields: array of UTF8String; AUpsert, ANew: Boolean): IBson;
begin
  Result := FindAndModify(AQuery, AUpdate, false, AUpsert, ANew, ASort, AFields);
end;

function TMongoCollection.FindAndModify(const AQuery, AUpdate: IBson; ARemove,
  AUpsert, ANew: Boolean; const ASort, AFields: array of UTF8String): IBson;
var
  sortBuf, fieldsBuf: IBsonBuffer;
  sort, fields: IBson;
  i: Integer;
begin
  Result := NewBson;

  if Length(ASort) > 0 then
  begin
    sortBuf := NewBsonBuffer;
    for i := Low(ASort) to High(ASort) do
      sortBuf.append(ASort[i], 1);
    sort := sortBuf.finish;
  end;

  if Length(AFields) > 0 then
  begin
    fieldsBuf := NewBsonBuffer;
    for i := Low(AFields) to High(AFields) do
      fieldsBuf.append(AFields[i], 1);
    fields := fieldsBuf.finish;
  end;

  if not mongoc_collection_find_and_modify(FNativeCollection,
                                           NativeBsonOrNil(AQuery),
                                           NativeBsonOrNil(sort),
                                           NativeBsonOrNil(AUpdate),
                                           NativeBsonOrNil(fields),
                                           ARemove, AUpsert, ANew,
                                           Result.NativeBson, @FError) then
    raise EMongoCollection.Create(@FError);
end;

function TMongoCollection.FindAndModifyRemove(const AQuery: IBson;
  ASort, AFields: array of UTF8String): IBson;
var
  sort: IBson;
begin
  Result := FindAndModify(AQuery, sort, true, false, false, ASort, AFields);
end;

function TMongoCollection.GetCount(const AQuery: IBson; ASkip, ALimit: Int64;
  AReadPrefs: IMongoReadPrefs; AFlags: Integer): Int64;
begin
  Result := mongoc_collection_count(FNativeCollection, AFlags,
                                    NativeBsonOrNil(AQuery), ASkip, ALimit,
                                    NativeReadPrefsOrNil(AReadPrefs),
                                    @FError);
  if Result = -1 then
    raise EMongoCollection.Create(@FError);
end;

function TMongoCollection.GetName: UTF8String;
begin
  Result := UTF8String(mongoc_collection_get_name(FNativeCollection));
end;

function TMongoCollection.GetReadPrefs: IMongoReadPrefs;
var
  native_prefs: Pointer;
begin
  if FCachedReadPrefs = nil then
  begin
    native_prefs := mongoc_collection_get_read_prefs(FNativeCollection);
    FCachedReadPrefs := NewMongoReadPrefs(native_prefs, false);
  end;
  Result := FCachedReadPrefs;
end;

function TMongoCollection.GetStats: IBson;
begin
  Result := NewBson;
  if not mongoc_collection_stats(FNativeCollection, nil,
                                 Result.NativeBson, @FError) then
    raise EMongoCollection.Create(@FError);
end;

function TMongoCollection.GetWriteConcern: IMongoWriteConcern;
var
  native_wc: Pointer;
begin
  if FCachedMongoWriteConcern = nil then
  begin
    native_wc := mongoc_collection_get_write_concern(FNativeCollection);
    FCachedMongoWriteConcern := NewMongoWriteConcern(native_wc, false);
  end;
  Result := FCachedMongoWriteConcern;
end;

procedure TMongoCollection.Insert(const ADcoument: IBson;
  const AWriteConcern: IMongoWriteConcern; AFlags: Integer);
begin
  Assert(ADcoument <> nil);

  if not mongoc_collection_insert(FNativeCollection, AFlags, ADcoument.NativeBson,
                                  NativeWriteConcernOrNil(AWriteConcern),
                                  @FError) then
    raise EMongoCollection.Create(@FError);
end;

procedure TMongoCollection.Remove(const ASelector: IBson;
  const AWriteConcern: IMongoWriteConcern; AFlags: Integer);
begin
  Assert(ASelector <> nil);

  if not mongoc_collection_remove(FNativeCollection, AFlags, ASelector.NativeBson,
                                  NativeWriteConcernOrNil(AWriteConcern),
                                  @FError) then
    raise EMongoCollection.Create(@FError);
end;

procedure TMongoCollection.Rename(const ANewCollectionName: UTF8String);
begin
  Rename('', ANewCollectionName, false);
end;

procedure TMongoCollection.Rename(const ANewDbName,
  ANewCollectionName: UTF8String; ADropTargerBeforeRename: Boolean);
var
  newDbName: PAnsiChar;
begin
  if ANewDbName = '' then
    newDbName := nil
  else
    newDbName := PAnsiChar(ANewDbName);

  if not mongoc_collection_rename(FNativeCollection, newDbName,
                                  PAnsiChar(ANewCollectionName),
                                  ADropTargerBeforeRename,
                                  @FError) then
    raise EMongoCollection.Create(@FError);
end;

function TMongoCollection.RunCommand(const ACommand: IBson;
  const AReadPrefs: IMongoReadPrefs): IBson;
begin
  Assert(ACommand <> nil);

  Result := NewBson;
  if not mongoc_collection_command_simple(FNativeCollection, ACommand.NativeBson,
                                          NativeReadPrefsOrNil(AReadPrefs),
                                          Result.NativeBson,
                                          @FError) then
    raise EMongoCollection.Create(@FError);
end;

procedure TMongoCollection.SetReadPrefs(const APrefs: IMongoReadPrefs);
begin
  mongoc_collection_set_read_prefs(FNativeCollection, APrefs.NativeReadPrefs);
end;

procedure TMongoCollection.SetWriteConcern(
  const AWriteConcern: IMongoWriteConcern);
begin
  mongoc_collection_set_write_concern(FNativeCollection, AWriteConcern.NativeWriteConcern);
end;

procedure TMongoCollection.Update(const ASelector, AUpdate: IBson;
  const AWriteConcern: IMongoWriteConcern; AFlags: Integer);
begin
  Assert(ASelector <> nil);
  Assert(AUpdate <> nil);

  if not mongoc_collection_update(FNativeCollection, AFlags, ASelector.NativeBson,
                                  AUpdate.NativeBson,
                                  NativeWriteConcernOrNil(AWriteConcern),
                                  @FError) then
    raise EMongoCollection.Create(@FError);
end;

procedure TMongoCollection.Save(const ADocument: IBson;
  const AWriteConcern: IMongoWriteConcern);
begin
  Assert(ADocument <> nil);

  if not mongoc_collection_save(FNativeCollection, ADocument.NativeBson,
                                NativeWriteConcernOrNil(AWriteConcern),
                                @FError) then
    raise EMongoCollection.Create(@FError);
end;

function TMongoCollection.FindAndModify(const AQuery, AUpdate: IBson; AUpsert,
  ANew: Boolean): IBson;
var
  emptyArr: TStringArray;
begin
  SetLength(emptyArr, 0);
  Result := FindAndModify(AQuery, AUpdate, emptyArr, emptyArr, AUpsert, ANew);
end;

function TMongoCollection.FindAndModifyRemove(const AQuery: IBson): IBson;
var
  emptyArr: TStringArray;
begin
  SetLength(emptyArr, 0);
  Result := FindAndModifyRemove(AQuery, emptyArr, emptyArr);
end;

end.
