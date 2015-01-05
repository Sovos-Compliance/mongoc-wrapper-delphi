unit uMongoGridfs;

interface

uses
  uMongo, MongoBson, uMongoGridfsFile, uDelphi5;

type
  EMongoGridfs = class(EMongo);

  TMongoGridfs = class(TMongoObject)
  private
    FNativeGridfs: Pointer;
    FError: bson_error_t;
  public
    constructor Create(ANativeGridfs: Pointer);
    destructor Destroy; override;
    procedure Drop;
    function CreateFile(const AName: UTF8String; const AMetadata: IBson = nil;
                        const AContentType: UTF8String = ''): IMongoGridfsFile;
    function GetFileNames: TStringArray;
    function FindFile(const AQuery: IBson = nil): IMongoGridfsFile; overload;
    function FindFile(const AName: UTF8String): IMongoGridfsFile; overload;
  end;

implementation

uses
  uLibMongocAPI, uMongoCollection, uMongoCursor;

{ TMongoGridfs }

constructor TMongoGridfs.Create(ANativeGridfs: Pointer);
begin
  FNativeGridfs := ANativeGridfs;
end;

function TMongoGridfs.CreateFile(const AName: UTF8String;
  const AMetadata: IBson; const AContentType: UTF8String): IMongoGridfsFile;
var
  opt: mongoc_gridfs_file_opt_t;
begin
  FillChar(opt, SizeOf(opt), 0);
  with opt do
  begin
    filename := PAnsiChar(AName);
    if AMetadata <> nil then
      metadata := AMetadata.NativeBson;
    if AContentType <> '' then
      content_type := PAnsiChar(AContentType);
  end;

  Result := NewMongoGridfsFile(mongoc_gridfs_create_file(FNativeGridfs, @opt));
end;

destructor TMongoGridfs.Destroy;
begin
  mongoc_gridfs_destroy(FNativeGridfs);
  inherited;
end;

procedure TMongoGridfs.Drop;
begin
  if not mongoc_gridfs_drop(FNativeGridfs, @FError) then
    raise EMongoGridfs.Create(@Ferror);
end;

function TMongoGridfs.FindFile(const AName: UTF8String): IMongoGridfsFile;
var
  nativeFile: Pointer;
  err: bson_error_t;
begin
  nativeFile := mongoc_gridfs_find_one_by_filename(FNativeGridfs,
                                                   PAnsiChar(AName), @err);
  if nativeFile = nil then
    raise EMongoGridfs.Create(@err);

  Result := NewMongoGridfsFile(nativeFile);
end;

function TMongoGridfs.FindFile(const AQuery: IBson): IMongoGridfsFile;
var
  nativeFile: Pointer;
  err: bson_error_t;
  query: IBson;
begin
  if AQuery = nil then
    query := NewBson
  else
    query := AQuery;

  nativeFile := mongoc_gridfs_find_one(FNativeGridfs, query.NativeBson, @err);
  if nativeFile = nil then
    raise EMongoGridfs.Create('File not found');

  Result := NewMongoGridfsFile(nativeFile);
end;

function TMongoGridfs.GetFileNames: TStringArray;
const
  fields: array[0..0] of UTF8String = ('filename');
var
  coll: TMongoCollection;
  cursor: TMongoCursor;
  it: IBsonIterator;
  i: Integer;
begin
  coll := TMongoCollection.Create(mongoc_gridfs_get_files(FNativeGridfs), false);
  try
    SetLength(Result, coll.GetCount);
    cursor := coll.Find(BSON([]), fields);
    try
      i := 0;
      while cursor.Next do
      begin
        it := cursor.Current.find('filename');
        Assert(it <> nil);
        Result[i] := it.AsUTF8String;
        Inc(i);
      end;
    finally
      cursor.Free;
    end;
  finally
    coll.Free;
  end;
end;

end.
