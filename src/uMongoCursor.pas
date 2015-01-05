unit uMongoCursor;

interface

uses
  MongoBson;

type
  TMongoCursor = class
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

implementation

uses
  uLibMongocAPI;

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

end.
