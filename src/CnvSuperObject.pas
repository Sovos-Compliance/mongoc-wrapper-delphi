unit CnvSuperObject;

interface

uses
  SuperObject;

type
  TCnvSuperObject = class(TSuperObject)
  protected
    function _AddRef: Integer; override; stdcall;
    function _Release: Integer; override; stdcall;
  end;

implementation

function TCnvSuperObject._AddRef: Integer;
begin
  Result := -1;
end;

function TCnvSuperObject._Release: Integer;
begin
  Result := -1;
end;

end.
