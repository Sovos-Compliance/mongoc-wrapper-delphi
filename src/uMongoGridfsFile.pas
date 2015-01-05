unit uMongoGridfsFile;

interface

{ TODO:
  mongoc_gridfs_file_get_aliases
  mongoc_gridfs_file_set_aliases
}

uses
  uMongo, MongoBson, Classes, uDelphi5;

type
  EMongoGridfsFile = class(EMongo);

  IMongoGridfsFile = interface
  ['{ead66aed-4e63-4602-b666-615f2a07a359}']
    function GetName: UTF8String;
    function GetSize: Int64;
    function GetMd5: UTF8String;
    function GetContentType: UTF8String;
    function GetChunkSize: LongInt;
    function GetUploadDate: TDateTime;
    function GetMetaData: IBson;
    function GetPosition: Int64;
    procedure SetName(const AName: UTF8String);
    procedure SetMd5(const AMd5: UTF8String);
    procedure SetContentType(const AContentType: UTF8String);
    procedure SetMetaData(const AMetaData: IBson);
    procedure Save;
    function Write(const ABuf; ASize: NativeUint): NativeUint;
    function Read(var ABuf; ASize: NativeUint): NativeUint;
    procedure Seek(Offset: Int64; Origin: TSeekOrigin);
    property Name: UTF8String read GetName write SetName;
    property Size: Int64 read GetSize;
    property Md5: UTF8String read GetMd5 write SetMd5;
    property ContentType: UTF8String read GetContentType write SetContentType;
    property ChunkSize: LongInt read GetChunkSize;
    property UploadDate: TDateTime read GetUploadDate;
    property MetaData: IBson read GetMetaData write SetMetaData;
    property Position: Int64 read GetPosition;
  end;

  function NewMongoGridfsFile(ANativeFile: Pointer): IMongoGridfsFile;

implementation

uses
  uLibMongocAPI, DateUtils;

type
  TMongoGridfsFile = class(TMongoObject, IMongoGridfsFile)
  private
    FNativeFile: Pointer;
    function GetName: UTF8String;
    function GetSize: Int64;
    function GetMd5: UTF8String;
    function GetContentType: UTF8String;
    function GetChunkSize: LongInt;
    function GetUploadDate: TDateTime;
    function GetMetaData: IBson;
    function GetPosition: Int64;
    procedure SetName(const AName: UTF8String);
    procedure SetMd5(const AMd5: UTF8String);
    procedure SetContentType(const AContentType: UTF8String);
    procedure SetMetaData(const AMetaData: IBson);
  public
    constructor Create(ANativeFile: Pointer);
    destructor Destroy; override;
    procedure Save;
    function Write(const ABuf; ASize: NativeUint): NativeUint;
    function Read(var ABuf; ASize: NativeUint): NativeUint;
    procedure Seek(Offset: Int64; Origin: TSeekOrigin);
    property Name: UTF8String read GetName write SetName;
    property Size: Int64 read GetSize;
    property Md5: UTF8String read GetMd5 write SetMd5;
    property ContentType: UTF8String read GetContentType write SetContentType;
    property ChunkSize: LongInt read GetChunkSize;
    property UploadDate: TDateTime read GetUploadDate;
    property MetaData: IBson read GetMetaData write SetMetaData;
    property Position: Int64 read GetPosition;
  end;

{ TMongoGridfsFile }

constructor TMongoGridfsFile.Create(ANativeFile: Pointer);
begin
  FNativeFile := ANativeFile;
end;

destructor TMongoGridfsFile.Destroy;
begin
  mongoc_gridfs_file_destroy(FNativeFile);
  inherited;
end;

function TMongoGridfsFile.GetChunkSize: LongInt;
begin
  Result := mongoc_gridfs_file_get_chunk_size(FNativeFile);
end;

function TMongoGridfsFile.GetContentType: UTF8String;
begin
  Result := UTF8String(mongoc_gridfs_file_get_content_type(FNativeFile));
end;

function TMongoGridfsFile.GetMd5: UTF8String;
begin
  Result := UTF8String(mongoc_gridfs_file_get_md5(FNativeFile));
end;

function TMongoGridfsFile.GetMetaData: IBson;
var
  nativeMetadata: bson_p;
begin
  nativeMetadata := mongoc_gridfs_file_get_metadata(FNativeFile);
  if nativeMetadata <> nil then
    Result := NewBson(nativeMetadata);
end;

function TMongoGridfsFile.GetName: UTF8String;
begin
  Result := UTF8String(mongoc_gridfs_file_get_filename(FNativeFile));
end;

function TMongoGridfsFile.GetPosition: Int64;
begin
  Result := mongoc_gridfs_file_tell(FNativeFile);
end;

function TMongoGridfsFile.GetSize: Int64;
begin
  Result := mongoc_gridfs_file_get_length(FNativeFile);
end;

function TMongoGridfsFile.GetUploadDate: TDateTime;
var
  utc_seconds: Int64;
begin
  utc_seconds := mongoc_gridfs_file_get_upload_date(FNativeFile) div 1000;
  Result := UnixToDateTime(utc_seconds);
end;

function TMongoGridfsFile.Read(var ABuf; ASize: NativeUint): NativeUint;
var
  err: bson_error_t;
  iov: mongoc_iovec_t;
  ret: NativeInt;
begin
  iov.iov_len := ASize;
  iov.iov_base := PAnsiChar(@ABuf);
  ret := mongoc_gridfs_file_readv(FNativeFile, @iov, 1, 0, 0);
  if ret < 0 then
  begin
    mongoc_gridfs_file_error(FNativeFile, @err);
    raise EMongoGridfsFile.Create(@err);
  end;

  Result := ret;
end;

procedure TMongoGridfsFile.Save;
var
  err: bson_error_t;
begin
  if not mongoc_gridfs_file_save(FNativeFile) then
  begin
    mongoc_gridfs_file_error(FNativeFile, @err);
    raise EMongoGridfsFile.Create(@err);
  end;
end;

procedure TMongoGridfsFile.Seek(Offset: Int64; Origin: TSeekOrigin);
begin
  if Origin = soEnd then
    // fix weird native implementation
    Inc(Offset);
  if mongoc_gridfs_file_seek(FNativeFile, UInt64(Offset), Integer(Origin)) <> 0 then
    raise EMongoGridfsFile.Create('mongoc_gridfs_file_seek failed');
end;

procedure TMongoGridfsFile.SetContentType(const AContentType: UTF8String);
begin
  mongoc_gridfs_file_set_content_type(FNativeFile, PAnsiChar(AContentType));
end;

procedure TMongoGridfsFile.SetMd5(const AMd5: UTF8String);
begin
  mongoc_gridfs_file_set_md5(FNativeFile, PAnsiChar(AMd5));
end;

procedure TMongoGridfsFile.SetMetaData(const AMetaData: IBson);
begin
  mongoc_gridfs_file_set_metadata(FNativeFile, NativeBsonOrNil(AMetaData));
end;

procedure TMongoGridfsFile.SetName(const AName: UTF8String);
begin
  mongoc_gridfs_file_set_filename(FNativeFile, PAnsiChar(AName));
end;

function TMongoGridfsFile.Write(const ABuf; ASize: NativeUint): NativeUint;
var
  err: bson_error_t;
  iov: mongoc_iovec_t;
  ret: NativeInt;
begin
  iov.iov_len := ASize;
  iov.iov_base := PAnsiChar(ABuf);
  ret := mongoc_gridfs_file_writev(FNativeFile, @iov, 1, 0);
  if ret < 0 then
  begin
    mongoc_gridfs_file_error(FNativeFile, @err);
    raise EMongoGridfsFile.Create(@err);
  end;

  Result := ret;
end;

function NewMongoGridfsFile(ANativeFile: Pointer): IMongoGridfsFile;
begin
  Result := TMongoGridfsFile.Create(ANativeFile);
end;

end.
