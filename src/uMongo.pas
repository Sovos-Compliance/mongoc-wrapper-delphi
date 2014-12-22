unit uMongo;

interface

uses
  SysUtils,
  LibBsonAPI;

type
  EMongo = class(Exception)
    constructor Create(const bson_err: bson_error_p); overload;
  end;

implementation

{ EMongo }

constructor EMongo.Create(const bson_err: bson_error_p);
begin
  inherited Create(string(bson_err^.message));
end;

end.
