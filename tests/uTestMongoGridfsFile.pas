unit uTestMongoGridfsFile;

interface

uses
  TestFramework,
  uTestMongo, uTestMongoGridfs, uMongoGridfsFile;

type
  TestMongoGridfsFile = class(TMongoGridfsTestCase)
  private
    FFile: IMongoGridfsFile;
    FBuf: array[0..255] of Byte;
  published
    procedure Getters;
    procedure Setters;
    procedure Write;
    procedure Read;
    procedure Seek;
    procedure SeekEnd;
    procedure Position;
  end;

implementation

uses
  SysUtils, Classes, MongoBson, uDelphi5;

const
  TEST_DATA: PAnsiChar = 'test read file';

{ TestMongoGridfsFile }

procedure TestMongoGridfsFile.Getters;
const
  // skip seconds case then can be different
  DATE_FORMAT_EXCEPT_SECOND = 'd/m/y hh:nn';
var
  createDate: TDateTime;
begin
  CreateFileStub('test');
  createDate := NowUTC;

  FFile := FGridfs.FindFile;
  CheckEqualsString('test', string(FFile.Name));
  CheckEquals(0, FFile.Size);
  CheckEquals(255 * 1024, FFile.ChunkSize);
  Check(FFile.MetaData = nil);
  CheckEqualsString('', string(FFile.ContentType));
  CheckEqualsString('', string(FFile.Md5));

  CheckEqualsString(FormatDateTime(DATE_FORMAT_EXCEPT_SECOND, createDate),
                    FormatDateTime(DATE_FORMAT_EXCEPT_SECOND, FFile.UploadDate));
end;

procedure TestMongoGridfsFile.Position;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := FGridfs.FindFile;

  CheckEquals(0, FFile.Position);

  FFile.Seek(9, soBeginning);
  CheckEquals(9, FFile.Position);

  FFile.Seek(2, soCurrent);
  CheckEquals(11, FFile.Position);

  FFile.Seek(-5, soCurrent);
  CheckEquals(6, FFile.Position);

  FFile.Seek(-2, soEnd);
  CheckEquals(12, FFile.Position);
end;

procedure TestMongoGridfsFile.Read;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := FGridfs.FindFile;
  CheckEquals(Length(TEST_DATA), FFile.Read(FBuf, SizeOf(FBuf)));
end;

procedure TestMongoGridfsFile.Seek;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := FGridfs.FindFile;
  FFile.Seek(5, soBeginning);
  CheckEquals(9, FFile.Read(FBuf, SizeOf(FBuf)));
  Check(CompareMem(@TEST_DATA[5], @FBuf, 9));
end;

procedure TestMongoGridfsFile.SeekEnd;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := FGridfs.FindFile;
  FFile.Seek(-3, soEnd);
  CheckEquals(3, FFile.Read(FBuf, SizeOf(FBuf)));
  Check(CompareMem(@TEST_DATA[11], @FBuf, 3));
end;

procedure TestMongoGridfsFile.Setters;
var
  it: IBsonIterator;
begin
  CreateFileStub('test');

  FFile := FGridfs.FindFile;
  FFile.Name := 'changed';
  FFile.ContentType := 'text';
  FFile.Md5 := 'some hash';
  FFile.MetaData := BSON(['a', 1, 'b', 'test']);
  FFile.Save;

  FFile := FGridfs.FindFile;
  CheckEqualsString('changed', string(FFile.Name));
  CheckEqualsString('text', string(FFile.ContentType));
  CheckEqualsString('some hash', string(FFile.Md5));
  it := FFile.MetaData.find('a');
  Check(it <> nil);
  CheckEquals(1, it.AsInteger);
  it := FFile.MetaData.find('b');
  Check(it <> nil);
  CheckEqualsString('test', string(it.AsUTF8String));
end;

procedure TestMongoGridfsFile.Write;
const
  DATA: PAnsiChar = 'hello world';
begin
  FFile := FGridfs.CreateFile('test_write');
  CheckEquals(11, FFile.Write(PByte(DATA), Length(DATA)));
  FFile.Save;

  FFile := FGridfs.FindFile;
  CheckEquals(11, FFile.Size);
end;

initialization
  RegisterTest(TestMongoGridfsFile.Suite);

end.
