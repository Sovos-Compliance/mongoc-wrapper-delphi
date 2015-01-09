unit uMongoCursor;

interface

uses
  MongoBson;

type
  IMongoCursor = interface
    function GetAlive: Boolean;
    function GetCurrent: IBson;
    function Next: Boolean;
    property Alive: Boolean read GetAlive;
    property Current: IBson read GetCurrent;
  end;

  function NewMongoCursor(ANativeCursor: Pointer): IMongoCursor;

implementation

uses
  uLibMongocAPI;

type
  TMongoCursor = class(TInterfacedObject, IMongoCursor)
  private
    FNativeCursor: Pointer;
    FCachedCurrent: IBson;
    function GetAlive: Boolean;
    function GetCurrent: IBson;
  public
    constructor Create(ANativeCursor: Pointer);
    destructor Destroy; override;
    function Next: Boolean;
    property Alive: Boolean read GetAlive;
    property Current: IBson read GetCurrent;
  end;

{ TMongoCursor }

constructor TMongoCursor.Create(ANativeCursor: Pointer);
begin
  FNativeCursor := ANativeCursor;
end;

destructor TMongoCursor.Destroy;
begin
  mongoc_cursor_destroy(FNativeCursor);
  inherited;
end;

function TMongoCursor.GetAlive: Boolean;
begin
  Result := mongoc_cursor_is_alive(FNativeCursor);
end;

function TMongoCursor.GetCurrent: IBson;
begin
  Result := FCachedCurrent;
end;

function TMongoCursor.Next: Boolean;
var
  b: bson_p;
begin
  Result := mongoc_cursor_next(FNativeCursor, @b);
  if Result then
    FCachedCurrent := NewBson(b);
end;

function NewMongoCursor(ANativeCursor: Pointer): IMongoCursor;
begin
  Result := TMongoCursor.Create(ANativeCursor);
end;

end.
