unit LibBsonAPI;

interface

uses
  SysUtils, MongoBson, Windows, uDelphi5;

const
  (* PLEASE!!! maintain this constant in sync with the dll driver version this code operates with *)
  LibBson_DllVersion = '1-3-0';

  CPUType = {$IFDEF WIN64} '64' {$ELSE} '32' {$ENDIF};
  ConfigType = {$IFDEF DEBUG} 'd' {$ELSE} 'r' {$ENDIF};
  LibBson_DLL = 'mongo-client_' + ConfigType + CPUType + '_v' + LibBson_DllVersion + '.dll';

type
  // we don't care about details, we just know bson_iter_t aligned to 128
  bson_iter_p = ^bson_iter_t;
  bson_iter_t = array[0..127] of Byte;

  PPByte = ^PByte;

{$IFNDEF OnDemandLibbsonLoad}
function bson_malloc(length : Cardinal) : Pointer; cdecl; external LibBson_DLL;
function bson_alloc : Pointer; cdecl; external LibBson_DLL;
procedure bson_free(mem : Pointer); cdecl; external LibBson_DLL;
procedure bson_strfreev(strv : PPAnsiChar); cdecl; external LibBson_DLL;

function bson_new : bson_p; cdecl; external LibBson_DLL;
function bson_new_from_data(const data : PByte; length : Cardinal) : bson_p; cdecl; external LibBson_DLL;
function bson_new_from_json(const data : PAnsiChar; length : Integer; error : bson_error_p) : bson_p; cdecl; external LibBson_DLL;
function bson_copy(const bson : bson_p) : Pointer; cdecl; external LibBson_DLL;
procedure bson_copy_to(const src : bson_p; dst : bson_p); cdecl; external LibBson_DLL;
procedure bson_init(bson : bson_p); cdecl; external LibBson_DLL;
function bson_init_from_json(bson : bson_p; const json: PAnsiChar; len : Integer; error : bson_error_p) : ByteBool;
  cdecl; external LibBson_DLL;
function bson_init_static(bson : bson_p; const data : PByte; length : Cardinal) : ByteBool;
  cdecl; external LibBson_DLL;
procedure bson_destroy(bson : bson_p); cdecl; external LibBson_DLL;
function bson_concat(dst : bson_p; const src : bson_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_get_data(const bson : bson_p) : PByte; cdecl; external LibBson_DLL;
function bson_as_json(const bson : bson_p; length : PCardinal) : PAnsiChar; cdecl; external LibBson_DLL;
function bson_append_utf8(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const value : PAnsiChar; length : Integer) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_code(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const javascript : PAnsiChar) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_symbol(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const value : PAnsiChar; length : Integer) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_int32(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  value : LongInt) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_int64(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  value : Int64) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_double(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  value : Double) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_date_time(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  value : Int64) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_bool(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  value : ByteBool) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_oid(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const value : PBsonOIDBytes) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_code_with_scope(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const javascript : PAnsiChar; const scope : Pointer) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_regex(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const regex : PAnsiChar; const options : PAnsiChar) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_timestamp(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  timestamp : LongWord; increment : LongWord) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_binary(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  subtype : TBsonSubtype; const binary : PByte; length : LongWord) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_null(bson : bson_p; const key : PAnsiChar; key_length : Integer) : ByteBool;
  cdecl; external LibBson_DLL;
function bson_append_undefined(bson : bson_p; const key : PAnsiChar; key_length : Integer) : ByteBool;
  cdecl; external LibBson_DLL;
function bson_append_document(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  const value: bson_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_document_begin(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  child: bson_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_document_end(bson, child : bson_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_array_begin(bson : bson_p; const key : PAnsiChar; key_length : Integer;
  child: Pointer) : ByteBool; cdecl; external LibBson_DLL;
function bson_append_array_end(bson, child : bson_p) : ByteBool; cdecl; external LibBson_DLL;

procedure bson_oid_init(oid : PBsonOIDBytes; context : Pointer); cdecl; external LibBson_DLL;
procedure bson_oid_init_from_string(oid : PBsonOIDBytes; const str : PAnsiChar); cdecl; external LibBson_DLL;
procedure bson_oid_to_string(oid : PBsonOIDBytes; str : PAnsiChar); cdecl; external LibBson_DLL;

function bson_iter_init(iter : bson_iter_p; const bson : bson_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_iter_init_find(iter : bson_iter_p; const bson : bson_p; const key : PAnsiChar) : ByteBool;
  cdecl; external LibBson_DLL;
function bson_iter_type(const iter : bson_iter_p) : TBsonType; cdecl; external LibBson_DLL;
function bson_iter_next(iter : bson_iter_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_iter_key(const iter : bson_iter_p) : PAnsiChar; cdecl; external LibBson_DLL;
function bson_iter_recurse(const iter : bson_iter_p; child : bson_iter_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_iter_find_descendant(iter : bson_iter_p; const dotkey: PAnsiChar;
  descendant : bson_iter_p) : ByteBool; cdecl; external LibBson_DLL;

function bson_iter_oid(const iter : bson_iter_p) : PBsonOIDBytes; cdecl; external LibBson_DLL;
function bson_iter_int32(const iter : bson_iter_p) : LongInt; cdecl; external LibBson_DLL;
function bson_iter_int64(const iter : bson_iter_p) : Int64; cdecl; external LibBson_DLL;
function bson_iter_double(const iter : bson_iter_p) : Double; cdecl; external LibBson_DLL;
function bson_iter_utf8(const iter : bson_iter_p; length : PLongWord) : PAnsiChar; cdecl; external LibBson_DLL;
function bson_iter_date_time(const iter : bson_iter_p) : Int64; cdecl; external LibBson_DLL;
function bson_iter_bool(const iter : bson_iter_p) : ByteBool; cdecl; external LibBson_DLL;
function bson_iter_code(const iter : bson_iter_p; length : PLongWord) : PAnsiChar; cdecl; external LibBson_DLL;
function bson_iter_symbol(const iter : bson_iter_p; length : PLongWord) : PAnsiChar; cdecl; external LibBson_DLL;
function bson_iter_codewscope(const iter : bson_iter_p; length, scope_len : PLongWord;
  scope : PPByte) : PAnsiChar; cdecl; external LibBson_DLL;
function bson_iter_regex(const iter : bson_iter_p; options : PPAnsiChar) : PAnsiChar; cdecl; external LibBson_DLL;
procedure bson_iter_timestamp(const iter : bson_iter_p; timestamp, increment : PLongWord); cdecl; external LibBson_DLL;
procedure bson_iter_binary(const iter : bson_iter_p; subtype : PBsonSubtype; binary_len : PLongWord;
  binary : PPByte); cdecl; external LibBson_DLL;
{$ELSE}

procedure LoadLibbsonLibrary(const dll: string = LibBson_DLL);
procedure LoadLibbsonFunctions(const dll: HMODULE);
procedure FreeLibbsonLibrary;

type
  Tbson_alloc = function : Pointer; cdecl;
  Tbson_malloc = function(length : Cardinal) : Pointer; cdecl;
  Tbson_free = procedure(mem : Pointer); cdecl;
  Tbson_strfreev = procedure(strv : PPAnsiChar); cdecl;

  Tbson_new = function : bson_p; cdecl;
  Tbson_new_from_data = function(const data : PByte; length : Cardinal) : bson_p; cdecl;
  Tbson_new_from_json = function(const data : PAnsiChar; length : Integer; error : bson_error_p) : bson_p; cdecl;
  Tbson_copy = function(const bson : bson_p) : Pointer; cdecl;
  Tbson_copy_to = procedure(const src : bson_p; dst : bson_p); cdecl;
  Tbson_init = procedure(bson : bson_p); cdecl;
  Tbson_init_from_json = function(bson : bson_p; const json: PAnsiChar; len : Integer; error : bson_error_p) : ByteBool;
    cdecl;
  Tbson_init_static = function(bson : bson_p; const data : PByte; length : Cardinal) : ByteBool;
    cdecl;
  Tbson_destroy = procedure(bson : bson_p); cdecl;
  Tbson_concat = function(dst : bson_p; const src : bson_p) : ByteBool; cdecl;
  Tbson_get_data = function(const bson : bson_p) : PByte; cdecl;
  Tbson_as_json = function(const bson : bson_p; length : PCardinal) : PAnsiChar; cdecl;
  Tbson_append_utf8 = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const value : PAnsiChar; length : Integer) : ByteBool; cdecl;
  Tbson_append_code = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const javascript : PAnsiChar) : ByteBool; cdecl;
  Tbson_append_symbol = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const value : PAnsiChar; length : Integer) : ByteBool; cdecl;
  Tbson_append_int32 = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    value : LongInt) : ByteBool; cdecl;
  Tbson_append_int64 = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    value : Int64) : ByteBool; cdecl;
  Tbson_append_double = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    value : Double) : ByteBool; cdecl;
  Tbson_append_date_time = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    value : Int64) : ByteBool; cdecl;
  Tbson_append_bool = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    value : ByteBool) : ByteBool; cdecl;
  Tbson_append_oid = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const value : PBsonOIDBytes) : ByteBool; cdecl;
  Tbson_append_code_with_scope = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const javascript : PAnsiChar; const scope : Pointer) : ByteBool; cdecl;
  Tbson_append_regex = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const regex : PAnsiChar; const options : PAnsiChar) : ByteBool; cdecl;
  Tbson_append_timestamp = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    timestamp : LongWord; increment : LongWord) : ByteBool; cdecl;
  Tbson_append_binary = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    subtype : TBsonSubtype; const binary : PByte; length : LongWord) : ByteBool; cdecl;
  Tbson_append_null = function(bson : bson_p; const key : PAnsiChar; key_length : Integer) : ByteBool;
    cdecl;
  Tbson_append_undefined = function(bson : bson_p; const key : PAnsiChar; key_length : Integer) : ByteBool;
    cdecl;
  Tbson_append_document = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    const value: bson_p) : ByteBool; cdecl;
  Tbson_append_document_begin = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    child: bson_p) : ByteBool; cdecl;
  Tbson_append_document_end = function(bson, child : bson_p) : ByteBool; cdecl;
  Tbson_append_array_begin = function(bson : bson_p; const key : PAnsiChar; key_length : Integer;
    child: Pointer) : ByteBool; cdecl;
  Tbson_append_array_end = function(bson, child : bson_p) : ByteBool; cdecl;

  Tbson_oid_init = procedure(oid : PBsonOIDBytes; context : Pointer); cdecl;
  Tbson_oid_init_from_string = procedure(oid : PBsonOIDBytes; const str : PAnsiChar); cdecl;
  Tbson_oid_to_string = procedure(oid : PBsonOIDBytes; str : PAnsiChar); cdecl;

  Tbson_iter_init = function(iter : bson_iter_p; const bson : bson_p) : ByteBool; cdecl;
  Tbson_iter_init_find = function(iter : bson_iter_p; const bson : bson_p; const key : PAnsiChar) : ByteBool;
    cdecl;
  Tbson_iter_type = function(const iter : bson_iter_p) : TBsonType; cdecl;
  Tbson_iter_next = function(iter : bson_iter_p) : ByteBool; cdecl;
  Tbson_iter_key = function(const iter : bson_iter_p) : PAnsiChar; cdecl;
  Tbson_iter_recurse = function(const iter : bson_iter_p; child : bson_iter_p) : ByteBool; cdecl;
  Tbson_iter_find_descendant = function(iter : bson_iter_p; const dotkey: PAnsiChar;
    descendant : bson_iter_p) : ByteBool; cdecl;

  Tbson_iter_oid = function(const iter : bson_iter_p) : PBsonOIDBytes; cdecl;
  Tbson_iter_int32 = function(const iter : bson_iter_p) : LongInt; cdecl;
  Tbson_iter_int64 = function(const iter : bson_iter_p) : Int64; cdecl;
  Tbson_iter_double = function(const iter : bson_iter_p) : Double; cdecl;
  Tbson_iter_utf8 = function(const iter : bson_iter_p; length : PLongWord) : PAnsiChar; cdecl;
  Tbson_iter_date_time = function(const iter : bson_iter_p) : Int64; cdecl;
  Tbson_iter_bool = function(const iter : bson_iter_p) : ByteBool; cdecl;
  Tbson_iter_code = function(const iter : bson_iter_p; length : PLongWord) : PAnsiChar; cdecl;
  Tbson_iter_symbol = function(const iter : bson_iter_p; length : PLongWord) : PAnsiChar; cdecl;
  Tbson_iter_codewscope = function(const iter : bson_iter_p; length, scope_len : PLongWord;
    scope : PPByte) : PAnsiChar; cdecl;
  Tbson_iter_regex = function(const iter : bson_iter_p; options : PPAnsiChar) : PAnsiChar; cdecl;
  Tbson_iter_timestamp = procedure(const iter : bson_iter_p; timestamp, increment : PLongWord); cdecl;
  Tbson_iter_binary = procedure(const iter : bson_iter_p; subtype : PBsonSubtype; binary_len : PLongWord;
    binary : PPByte); cdecl;

var
  bson_alloc: Tbson_alloc;
  bson_malloc: Tbson_malloc;
  bson_free: Tbson_free;
  bson_strfreev: Tbson_strfreev;
  bson_new: Tbson_new;
  bson_new_from_data: Tbson_new_from_data;
  bson_new_from_json: Tbson_new_from_json;
  bson_copy: Tbson_copy;
  bson_copy_to: Tbson_copy_to;
  bson_init: Tbson_init;
  bson_init_from_json: Tbson_init_from_json;
  bson_init_static: Tbson_init_static;
  bson_destroy: Tbson_destroy;
  bson_concat: Tbson_concat;
  bson_get_data: Tbson_get_data;
  bson_as_json: Tbson_as_json;
  bson_append_utf8: Tbson_append_utf8;
  bson_append_code: Tbson_append_code;
  bson_append_symbol: Tbson_append_symbol;
  bson_append_int32: Tbson_append_int32;
  bson_append_int64: Tbson_append_int64;
  bson_append_double: Tbson_append_double;
  bson_append_date_time: Tbson_append_date_time;
  bson_append_bool: Tbson_append_bool;
  bson_append_oid: Tbson_append_oid;
  bson_append_code_with_scope: Tbson_append_code_with_scope;
  bson_append_regex: Tbson_append_regex;
  bson_append_timestamp: Tbson_append_timestamp;
  bson_append_binary: Tbson_append_binary;
  bson_append_null: Tbson_append_null;
  bson_append_undefined: Tbson_append_undefined;
  bson_append_document: Tbson_append_document;
  bson_append_document_begin: Tbson_append_document_begin;
  bson_append_document_end: Tbson_append_document_end;
  bson_append_array_begin: Tbson_append_array_begin;
  bson_append_array_end: Tbson_append_array_end;
  bson_oid_init: Tbson_oid_init;
  bson_oid_init_from_string: Tbson_oid_init_from_string;
  bson_oid_to_string: Tbson_oid_to_string;
  bson_iter_init: Tbson_iter_init;
  bson_iter_init_find: Tbson_iter_init_find;
  bson_iter_type: Tbson_iter_type;
  bson_iter_next: Tbson_iter_next;
  bson_iter_key: Tbson_iter_key;
  bson_iter_recurse: Tbson_iter_recurse;
  bson_iter_find_descendant: Tbson_iter_find_descendant;
  bson_iter_oid: Tbson_iter_oid;
  bson_iter_int32: Tbson_iter_int32;
  bson_iter_int64: Tbson_iter_int64;
  bson_iter_double: Tbson_iter_double;
  bson_iter_utf8: Tbson_iter_utf8;
  bson_iter_date_time: Tbson_iter_date_time;
  bson_iter_bool: Tbson_iter_bool;
  bson_iter_code: Tbson_iter_code;
  bson_iter_symbol: Tbson_iter_symbol;
  bson_iter_codewscope: Tbson_iter_codewscope;
  bson_iter_regex: Tbson_iter_regex;
  bson_iter_timestamp: Tbson_iter_timestamp;
  bson_iter_binary: Tbson_iter_binary;
{$ENDIF}
implementation

{$IFDEF OnDemandLibbsonLoad}
  
resourcestring
  SLoadDllFailed = 'Failed loading dll: %s';
  SLoadFuncFailed = 'Failed loading function %s from dll';
  
var
  HLibbson: HMODULE;

procedure LoadLibbsonFunctions(const dll: HMODULE);
var
  dllHandle: HMODULE;

  function LoadLibbsonFunc(const name: PAnsiChar) : Pointer;
  begin
    Result := GetProcAddress(dllHandle, name);
    if Result = nil then
      raise Exception.CreateFmt(SLoadFuncFailed, [name]);
  end;
begin
  dllHandle := dll;

  bson_alloc := LoadLibbsonFunc('bson_alloc');
  bson_malloc := LoadLibbsonFunc('bson_malloc');
  bson_free := LoadLibbsonFunc('bson_free');
  bson_strfreev := LoadLibbsonFunc('bson_strfreev');
  bson_new := LoadLibbsonFunc('bson_new');
  bson_new_from_data := LoadLibbsonFunc('bson_new_from_data');
  bson_new_from_json := LoadLibbsonFunc('bson_new_from_json');
  bson_copy := LoadLibbsonFunc('bson_copy');
  bson_copy_to := LoadLibbsonFunc('bson_copy_to');
  bson_init := LoadLibbsonFunc('bson_init');
  bson_init_from_json := LoadLibbsonFunc('bson_init_from_json');
  bson_init_static := LoadLibbsonFunc('bson_init_static');
  bson_destroy := LoadLibbsonFunc('bson_destroy');
  bson_concat := LoadLibbsonFunc('bson_concat');
  bson_get_data := LoadLibbsonFunc('bson_get_data');
  bson_as_json := LoadLibbsonFunc('bson_as_json');
  bson_append_utf8 := LoadLibbsonFunc('bson_append_utf8');
  bson_append_code := LoadLibbsonFunc('bson_append_code');
  bson_append_symbol := LoadLibbsonFunc('bson_append_symbol');
  bson_append_int32 := LoadLibbsonFunc('bson_append_int32');
  bson_append_int64 := LoadLibbsonFunc('bson_append_int64');
  bson_append_double := LoadLibbsonFunc('bson_append_double');
  bson_append_date_time := LoadLibbsonFunc('bson_append_date_time');
  bson_append_bool := LoadLibbsonFunc('bson_append_bool');
  bson_append_oid := LoadLibbsonFunc('bson_append_oid');
  bson_append_code_with_scope := LoadLibbsonFunc('bson_append_code_with_scope');
  bson_append_regex := LoadLibbsonFunc('bson_append_regex');
  bson_append_timestamp := LoadLibbsonFunc('bson_append_timestamp');
  bson_append_binary := LoadLibbsonFunc('bson_append_binary');
  bson_append_null := LoadLibbsonFunc('bson_append_null');
  bson_append_undefined := LoadLibbsonFunc('bson_append_undefined');
  bson_append_document := LoadLibbsonFunc('bson_append_document');
  bson_append_document_begin := LoadLibbsonFunc('bson_append_document_begin');
  bson_append_document_end := LoadLibbsonFunc('bson_append_document_end');
  bson_append_array_begin := LoadLibbsonFunc('bson_append_array_begin');
  bson_append_array_end := LoadLibbsonFunc('bson_append_array_end');
  bson_oid_init := LoadLibbsonFunc('bson_oid_init');
  bson_oid_init_from_string := LoadLibbsonFunc('bson_oid_init_from_string');
  bson_oid_to_string := LoadLibbsonFunc('bson_oid_to_string');
  bson_iter_init := LoadLibbsonFunc('bson_iter_init');
  bson_iter_init_find := LoadLibbsonFunc('bson_iter_init_find');
  bson_iter_type := LoadLibbsonFunc('bson_iter_type');
  bson_iter_next := LoadLibbsonFunc('bson_iter_next');
  bson_iter_key := LoadLibbsonFunc('bson_iter_key');
  bson_iter_recurse := LoadLibbsonFunc('bson_iter_recurse');
  bson_iter_find_descendant := LoadLibbsonFunc('bson_iter_find_descendant');
  bson_iter_oid := LoadLibbsonFunc('bson_iter_oid');
  bson_iter_int32 := LoadLibbsonFunc('bson_iter_int32');
  bson_iter_int64 := LoadLibbsonFunc('bson_iter_int64');
  bson_iter_double := LoadLibbsonFunc('bson_iter_double');
  bson_iter_utf8 := LoadLibbsonFunc('bson_iter_utf8');
  bson_iter_date_time := LoadLibbsonFunc('bson_iter_date_time');
  bson_iter_bool := LoadLibbsonFunc('bson_iter_bool');
  bson_iter_code := LoadLibbsonFunc('bson_iter_code');
  bson_iter_symbol := LoadLibbsonFunc('bson_iter_symbol');
  bson_iter_codewscope := LoadLibbsonFunc('bson_iter_codewscope');
  bson_iter_regex := LoadLibbsonFunc('bson_iter_regex');
  bson_iter_timestamp := LoadLibbsonFunc('bson_iter_timestamp');
  bson_iter_binary := LoadLibbsonFunc('bson_iter_binary');
end;
  
procedure LoadLibbsonLibrary(const dll: string);

begin
  if HLibbson <> 0 then
    exit;
  HLibbson := LoadLibraryA(PAnsiChar(AnsiString(dll)));
  if HLibbson = 0 then
    raise Exception.CreateFmt(SLoadDllFailed, [dll]);
  LoadLibbsonFunctions(HLibbson);
end;

procedure FreeLibbsonLibrary;
begin
  if HLibbson <> 0 then
  begin
    FreeLibrary(HLibbson);
    HLibbson := 0;
  end;
end;
{$ENDIF}

initialization
  Assert(sizeof(bson_t) = 128, 'Keep structure synced with libbson bson_t');
  Assert(sizeof(bson_iter_t) = 128, 'Keep structure synced with libbson bson_iter_t');
  Assert(sizeof(bson_error_t) = 512, 'Keep structure synced with libbson bson_error_t');

end.
