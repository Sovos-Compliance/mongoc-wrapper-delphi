unit uMongoGridfs;

interface

uses
  uMongo, MongoBson, uMongoGridfsFile, uDelphi5;

type
  TMongoFlag = (mfCompress, mfEncrypt, mfUncompress, mfDecrypt);
  TMongoFlags = set of TMongoFlag;

type
  EMongoGridfs = class(EMongo);

  IMongoGridfs = interface
    ['{c78da0ba-6665-4aa1-9c27-f47a1f3eda41}']
    procedure Drop;
    function CreateFile(const AName: UTF8String;
                        AFlags: TMongoFlags = [];
                        const AMetadata: IBson = nil;
                        const AContentType: UTF8String = ''): IMongoGridfsFile;
    function GetFileNames: TStringArray;
    function FindFile(const AQuery: IBson = nil;
                      AFlags: TMongoFlags = []): IMongoGridfsFile; overload;
    function FindFile(const AName: UTF8String;
                      AFlags: TMongoFlags = []): IMongoGridfsFile; overload;
    procedure RemoveFile(const AName: UTF8String);
  end;

  function NewMongoGridfs(ANativeGridfs: Pointer): IMongoGridfs;

implementation

uses
  uLibMongocAPI, uMongoCollection, uMongoCursor, uMongoReadPrefs;

type
  TMongoGridfs = class(TMongoObject, IMongoGridfs)
  private
    FNativeGridfs: Pointer;
    FError: bson_error_t;
    function FlagsToNative(AFlags: TMongoFlags): Integer;
    procedure RaiseFindFileError(err: bson_error_p);
  public
    constructor Create(ANativeGridfs: Pointer);
    destructor Destroy; override;
    procedure Drop;
    function CreateFile(const AName: UTF8String;
                        AFlags: TMongoFlags;
                        const AMetadata: IBson = nil;
                        const AContentType: UTF8String = ''): IMongoGridfsFile;
    function GetFileNames: TStringArray;
    function FindFile(const AQuery: IBson = nil;
                      AFlags: TMongoFlags = []): IMongoGridfsFile; overload;
    function FindFile(const AName: UTF8String;
                      AFlags: TMongoFlags): IMongoGridfsFile; overload;
    procedure RemoveFile(const AName: UTF8String);
  end;

{ TMongoGridfs }

constructor TMongoGridfs.Create(ANativeGridfs: Pointer);
begin
  FNativeGridfs := ANativeGridfs;
end;

function TMongoGridfs.CreateFile(const AName: UTF8String; AFlags: TMongoFlags;
  const AMetadata: IBson; const AContentType: UTF8String): IMongoGridfsFile;
var
  nativeFile: Pointer;
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

  nativeFile := mongoc_gridfs_create_cnv_file(FNativeGridfs, @opt,
                                              FlagsToNative(AFlags));
  Result := NewMongoGridfsFile(nativeFile);
end;

destructor TMongoGridfs.Destroy;
begin
  mongoc_gridfs_destroy(FNativeGridfs);
  inherited;
end;

procedure TMongoGridfs.Drop;
begin
  if not mongoc_gridfs_drop(FNativeGridfs, @FError) then
    raise EMongoGridfs.Create(@FError);
end;

function TMongoGridfs.FindFile(const AName: UTF8String;
  AFlags: TMongoFlags): IMongoGridfsFile;
var
  nativeFile: Pointer;
  err: bson_error_t;
begin
  FillChar(err, SizeOf(bson_error_t), 0);
  nativeFile := mongoc_gridfs_find_one_cnv_by_filename(FNativeGridfs,
                                                       PAnsiChar(AName),
                                                       @err, FlagsToNative(AFlags));
  if nativeFile = nil then
    RaiseFindFileError(@err);

  Result := NewMongoGridfsFile(nativeFile);
end;

function TMongoGridfs.FlagsToNative(AFlags: TMongoFlags): Integer;
begin
  Result := MONGOC_CNV_NONE;
  if mfCompress in AFlags then
    Result := Result or MONGOC_CNV_COMPRESS;
  if mfEncrypt in AFlags then
    Result := Result or MONGOC_CNV_ENCRYPT;
  if mfUncompress in AFlags then
    Result := Result or MONGOC_CNV_UNCOMPRESS;
  if mfDecrypt in AFlags then
    Result := Result or MONGOC_CNV_DECRYPT;
end;

function TMongoGridfs.FindFile(const AQuery: IBson;
  AFlags: TMongoFlags): IMongoGridfsFile;
var
  nativeFile: Pointer;
  err: bson_error_t;
  query: IBson;
begin
  FillChar(err, SizeOf(bson_error_t), 0);
  if AQuery = nil then
    query := NewBson
  else
    query := AQuery;

  nativeFile := mongoc_gridfs_find_one_cnv(FNativeGridfs,
                                           query.NativeBson, @err,
                                           FlagsToNative(AFlags));
  if nativeFile = nil then
    RaiseFindFileError(@err);

  Result := NewMongoGridfsFile(nativeFile);
end;

function TMongoGridfs.GetFileNames: TStringArray;
const
  fields: array[0..0] of UTF8String = ('filename');
var
  coll: TMongoCollection;
  cursor: IMongoCursor;
  it: IBsonIterator;
  i: Integer;
  nilReadPrefs: IMongoReadPrefs;
begin
  coll := TMongoCollection.Create(mongoc_gridfs_get_files(FNativeGridfs), false);
  try
    SetLength(Result, coll.GetCount);
    cursor := coll.Find(BSON([]), fields, 0, 0, 100, 0, nilReadPrefs);
    i := 0;
    while cursor.Next do
    begin
      it := cursor.Current.find('filename');
      Assert(it <> nil);
      Result[i] := it.AsUTF8String;
      Inc(i);
    end;
  finally
    coll.Free;
  end;
end;

procedure TMongoGridfs.RaiseFindFileError(err: bson_error_p);
begin
  if err.code = 0 then
    raise EMongoGridfs.Create('File not found')
  else
    raise EMongoGridfs.Create(@err);
end;

procedure TMongoGridfs.RemoveFile(const AName: UTF8String);
begin
  if not mongoc_gridfs_remove_by_filename(FNativeGridfs, PAnsiChar(AName),
                                          @FError) then
    raise EMongoGridfs.Create(@FError);
end;

function NewMongoGridfs(ANativeGridfs: Pointer): IMongoGridfs;
begin
  Result := TMongoGridfs.Create(ANativeGridfs);
end;

end.
