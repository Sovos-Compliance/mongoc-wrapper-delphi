unit uMongoReadPrefs;

interface

uses
  MongoBson;

const
  MONGOC_READ_PRIMARY = 1;
  MONGOC_READ_SECONDARY = 2;
  MONGOC_READ_PRIMARY_PREFERRED = 5;
  MONGOC_READ_SECONDARY_PREFERRED = 6;
  MONGOC_READ_NEAREST = 10;

type
  TMongoReadMode = LongInt; // see MONGOC_READ_* constants

  IMongoReadPrefs = interface
    ['{32cee1dd-c4ac-4397-bbe3-d3e4e48d3401}']
    function GetValid: Boolean;
    function GetTags: IBson;
    function GetMode: TMongoReadMode;
    function GetFNativeReadPrefs: Pointer;
    procedure SetTags(const ATags: IBson);
    procedure SetMode(AMode: TMongoReadMode);
    procedure AddMode(const ATag: IBson);
    property NativeReadPrefs: Pointer read GetFNativeReadPrefs;
    property Valid: Boolean read GetValid;
    property Tags: IBson read GetTags write SetTags;
    property Mode: TMongoReadMode read GetMode write SetMode;
  end;

  function NewMongoReadPrefs(AMode: TMongoReadMode): IMongoReadPrefs; overload;
  function NewMongoReadPrefs(ANativeReadPrefs: Pointer; AOwns: Boolean): IMongoReadPrefs; overload;
  function NewMongoReadPrefs(const AReadPrefs: IMongoReadPrefs): IMongoReadPrefs; overload;

implementation

uses
  uLibMongocAPI;

type
  TMongoReadPrefs = class(TInterfacedObject, IMongoReadPrefs)
  private
    FNativeReadPrefs: Pointer;
    FOwnsNativeReadPrefs: Boolean;
    FTags: IBson;
    function GetFNativeReadPrefs: Pointer;
    function GetValid: Boolean;
    function GetTags: IBson;
    function GetMode: TMongoReadMode;
    procedure SetTags(const ATags: IBson);
    procedure SetMode(AMode: TMongoReadMode);
  public
    constructor Create(mode: TMongoReadMode); overload;
    constructor Create(ANativeReadPrefs: Pointer; AOwns: Boolean); overload;
    constructor Create(const AReadPrefs: IMongoReadPrefs); overload;
    destructor Destroy; override;
    procedure AddMode(const ATag: IBson);
    property Valid: Boolean read GetValid;
    property Tags: IBson read GetTags write SetTags;
    property Mode: TMongoReadMode read GetMode write SetMode;
  end;

{ TMongoReadPrefs }

procedure TMongoReadPrefs.AddMode(const ATag: IBson);
begin
  mongoc_read_prefs_add_tag(FNativeReadPrefs, ATag.NativeBson);
end;

constructor TMongoReadPrefs.Create(mode: TMongoReadMode);
begin
  FTags := nil;
  FOwnsNativeReadPrefs := true;
  FNativeReadPrefs := mongoc_read_prefs_new(mode);
end;

constructor TMongoReadPrefs.Create(const AReadPrefs: IMongoReadPrefs);
begin
  FTags := nil;
  FOwnsNativeReadPrefs := true;
  FNativeReadPrefs := mongoc_read_prefs_copy(AReadPrefs.NativeReadPrefs);
end;

constructor TMongoReadPrefs.Create(ANativeReadPrefs: Pointer;
                                   AOwns: Boolean);
begin
  FTags := nil;
  FOwnsNativeReadPrefs := AOwns;
  FNativeReadPrefs := ANativeReadPrefs;
end;

destructor TMongoReadPrefs.Destroy;
begin
  if FOwnsNativeReadPrefs then
    mongoc_read_prefs_destroy(FNativeReadPrefs);
  inherited;
end;

function TMongoReadPrefs.GetFNativeReadPrefs: Pointer;
begin
  Result := FNativeReadPrefs;
end;

function TMongoReadPrefs.GetMode: TMongoReadMode;
begin
  Result := mongoc_read_prefs_get_mode(FNativeReadPrefs);
end;

function TMongoReadPrefs.GetTags: IBson;
begin
  if FTags = nil then
    FTags := NewBson(mongoc_read_prefs_get_tags(FNativeReadPrefs));
  Result := FTags;
end;

function TMongoReadPrefs.GetValid: Boolean;
begin
  Result := mongoc_read_prefs_is_valid(FNativeReadPrefs);
end;

procedure TMongoReadPrefs.SetMode(AMode: TMongoReadMode);
begin
  mongoc_read_prefs_set_mode(FNativeReadPrefs, AMode);
end;

procedure TMongoReadPrefs.SetTags(const ATags: IBson);
begin
  mongoc_read_prefs_set_tags(FNativeReadPrefs, ATags.NativeBson);
end;

function NewMongoReadPrefs(AMode: TMongoReadMode): IMongoReadPrefs;
begin
  Result := TMongoReadPrefs.Create(AMode);
end;

function NewMongoReadPrefs(ANativeReadPrefs: Pointer; AOwns: Boolean): IMongoReadPrefs;
begin
  Result := TMongoReadPrefs.Create(ANativeReadPrefs, AOwns);
end;

function NewMongoReadPrefs(const AReadPrefs: IMongoReadPrefs): IMongoReadPrefs;
begin
  Result := TMongoReadPrefs.Create(AReadPrefs);
end;

end.
