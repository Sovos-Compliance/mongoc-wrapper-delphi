unit uMongoWriteConcern;

interface

type
  TMongoWriteConcernW = (
    UNACKNOWLEDGED =  0,
    ERRORS_IGNORED = -1,
    DEFAULT        = -2,
    MAJORITY       = -3,
    TAG            = -4
  );

  IMongoWriteConcern = interface
    ['{52ce95f7-6968-46e1-9758-d4947376a5f6}']
    function GetFsync: Boolean;
    procedure SetFsync(AFsync: Boolean);
    function GetJournal: Boolean;
    procedure SetJournal(AJournal: Boolean);
    function GetW: TMongoWriteConcernW;
    procedure SetW(AW: TMongoWriteConcernW);
    function GetWMajority: Boolean;
    procedure SetWMajority(AWTimeOutMsec: Longint);
    function GetWTag: UTF8String;
    procedure SetWTag(AWTag: UTF8String);
    function GetWTimeOut: Longint;
    procedure SetWTimeOut(AWTimeOutMsec: Longint);
    function GetNativeWriteConcern: Pointer;
    property Fsync: Boolean read GetFsync write SetFsync;
    property Journal: Boolean read GetJournal write SetJournal;
    property W: TMongoWriteConcernW read GetW write SetW;
    property WTag: UTF8String read GetWTag write SetWTag;
    property WTimeOut: Longint read GetWTimeOut write SetWTimeOut;
    property NativeWriteConcern: Pointer read GetNativeWriteConcern;
  end;

  function NewMongoWriteConcern: IMongoWriteConcern; overload;
  function NewMongoWriteConcern(ANativeWriteConcern: Pointer; AOwns: Boolean): IMongoWriteConcern; overload;
  function NewMongoWriteConcern(const AWriteConcern: IMongoWriteConcern): IMongoWriteConcern; overload;

implementation

uses
  uLibMongocAPI;

type
  TMongoWriteConcern = class(TInterfacedObject, IMongoWriteConcern)
  private
    FNativeWriteConcern: Pointer;
    FOwnsNativeWriteConcern: Boolean;
    function GetFsync: Boolean;
    procedure SetFsync(AFsync: Boolean);
    function GetJournal: Boolean;
    procedure SetJournal(AJournal: Boolean);
    function GetW: TMongoWriteConcernW;
    procedure SetW(AW: TMongoWriteConcernW);
    function GetWTag: UTF8String;
    procedure SetWTag(AWTag: UTF8String);
    function GetWTimeOut: Longint;
    procedure SetWTimeOut(AWTimeOutMsec: Longint);
    function GetNativeWriteConcern: Pointer;
  public
    constructor Create; overload;
    constructor Create(ANativeWriteConcern: Pointer; AOwns: Boolean); overload;
    constructor Create(const AWriteConcern: IMongoWriteConcern); overload;
    destructor Destroy; override;
    function GetWMajority: Boolean;
    procedure SetWMajority(AWTimeOutMsec: Longint);
    property Fsync: Boolean read GetFsync write SetFsync;
    property Journal: Boolean read GetJournal write SetJournal;
    property W: TMongoWriteConcernW read GetW write SetW;
    property WTag: UTF8String read GetWTag write SetWTag;
    property WTimeOut: Longint read GetWTimeOut write SetWTimeOut;
    property NativeWriteConcern: Pointer read GetNativeWriteConcern;
  end;

{ TMongoWriteConcern }

constructor TMongoWriteConcern.Create;
begin
  FNativeWriteConcern := mongoc_write_concern_new;
  FOwnsNativeWriteConcern := true;
end;

constructor TMongoWriteConcern.Create(const AWriteConcern: IMongoWriteConcern);
begin
  FNativeWriteConcern := mongoc_write_concern_copy(AWriteConcern.NativeWriteConcern);
  FOwnsNativeWriteConcern := true;
end;

constructor TMongoWriteConcern.Create(ANativeWriteConcern: Pointer;
  AOwns: Boolean);
begin
  FNativeWriteConcern := ANativeWriteConcern;
  FOwnsNativeWriteConcern := AOwns;
end;

destructor TMongoWriteConcern.Destroy;
begin
  if FOwnsNativeWriteConcern then
    mongoc_write_concern_destroy(FNativeWriteConcern);
  inherited;
end;

function TMongoWriteConcern.GetFsync: Boolean;
begin
  Result := mongoc_write_concern_get_fsync(FNativeWriteConcern) <> 0;
end;

function TMongoWriteConcern.GetJournal: Boolean;
begin
  Result := mongoc_write_concern_get_journal(FNativeWriteConcern) <> 0;
end;

function TMongoWriteConcern.GetNativeWriteConcern: Pointer;
begin
  Result := FNativeWriteConcern;
end;

function TMongoWriteConcern.GetW: TMongoWriteConcernW;
begin
  Result := TMongoWriteConcernW(mongoc_write_concern_get_w(FNativeWriteConcern));
end;

function TMongoWriteConcern.GetWMajority: Boolean;
begin
  Result := mongoc_write_concern_get_wmajority(FNativeWriteConcern) <> 0;
end;

function TMongoWriteConcern.GetWTag: UTF8String;
begin
  Result := UTF8String(mongoc_write_concern_get_wtag(FNativeWriteConcern));
end;

function TMongoWriteConcern.GetWTimeOut: Longint;
begin
  Result := mongoc_write_concern_get_wtimeout(FNativeWriteConcern);
end;

procedure TMongoWriteConcern.SetFsync(AFsync: Boolean);
begin
  mongoc_write_concern_set_fsync(FNativeWriteConcern, Byte(AFsync));
end;

procedure TMongoWriteConcern.SetJournal(AJournal: Boolean);
begin
  mongoc_write_concern_set_journal(FNativeWriteConcern, Byte(AJournal));
end;

procedure TMongoWriteConcern.SetW(AW: TMongoWriteConcernW);
begin
  mongoc_write_concern_set_w(FNativeWriteConcern, Longint(AW));
end;

procedure TMongoWriteConcern.SetWMajority(AWTimeOutMsec: Longint);
begin
  mongoc_write_concern_set_wmajority(FNativeWriteConcern, AWTimeOutMsec);
end;

procedure TMongoWriteConcern.SetWTag(AWTag: UTF8String);
begin
  mongoc_write_concern_set_wtag(FNativeWriteConcern, PAnsiChar(AWTag));
end;

procedure TMongoWriteConcern.SetWTimeOut(AWTimeOutMsec: Longint);
begin
  mongoc_write_concern_set_wtimeout(FNativeWriteConcern, AWTimeOutMsec);
end;

{ New }

function NewMongoWriteConcern: IMongoWriteConcern;
begin
  Result := TMongoWriteConcern.Create;
end;

function NewMongoWriteConcern(ANativeWriteConcern: Pointer; AOwns: Boolean): IMongoWriteConcern;
begin
  Result := TMongoWriteConcern.Create(ANativeWriteConcern, AOwns);
end;

function NewMongoWriteConcern(const AWriteConcern: IMongoWriteConcern): IMongoWriteConcern;
begin
  Result := TMongoWriteConcern.Create(AWriteConcern);
end;

end.
