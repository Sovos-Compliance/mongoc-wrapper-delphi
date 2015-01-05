unit uTestMongoGridfs;

interface

uses
  TestFramework,
  uTestMongo;

type
  TestMongoGridfs = class(TMongoGridfsTestCase)
  published
    procedure Drop;
    procedure GetFileNames;
    procedure CreateFile;
    procedure FindFile;
    procedure FindFileByName;
  end;

implementation

uses
  MongoBson, uMongoGridfs, uMongoGridfsFile;

{ TestMongoGridfs }

procedure TestMongoGridfs.CreateFile;
var
  f: IMongoGridfsFile;
  names: TStringArray;
begin
  f := FGridfs.CreateFile('test');
  f.Save;

  names := FGridfs.GetFileNames;
  CheckEquals(1, Length(names));
  CheckEqualsString('test', string(names[0]));
end;

procedure TestMongoGridfs.Drop;
begin
  try
    FGridfs.Drop;
    Fail('EMongoGridfs expected');
  except
    on e: EMongoGridfs do
      CheckEqualsString('ns not found', e.Message);
  end;
end;

procedure TestMongoGridfs.FindFile;
var
  f: IMongoGridfsFile;
begin
  CreateFileStub('test');

  f := FGridfs.FindFile;
  CheckEqualsString('test', string(f.Name));
  CheckEquals(0, f.Size);
end;

procedure TestMongoGridfs.FindFileByName;
var
  f: IMongoGridfsFile;
begin
  CreateFileStub('test');

  f := FGridfs.FindFile('test');
  CheckEqualsString('test', string(f.Name));
  CheckEquals(0, f.Size);
end;

procedure TestMongoGridfs.GetFileNames;
var
  names: TStringArray;
begin
  names := FGridfs.GetFileNames;
  CheckEquals(0, Length(names));
end;

initialization
  RegisterTest(TestMongoGridfs.Suite);

end.
