unit uTestMongoGridfsFile;

interface

uses
  TestFramework,
  uTestMongo, uTestMongoGridfs, uMongoGridfs, uMongoGridfsFile, uDelphi5;

type
  TestMongoGridfsFile = class(TMongoGridfsTestCase)
  private
    FFile: IMongoGridfsFile;
    FBuf: array[0..255] of AnsiChar;
    procedure Check_Write_Read(AWriteFlags, AReadFlags: TMongoFlags; ASize: NativeUint);
  published
    procedure Getters;
    procedure Setters;
    procedure Write;
    procedure Read;
    procedure Seek;
    procedure SeekEnd;
    procedure Position;
    procedure Size;
    procedure Write_Seek_Read;
    procedure Write_Read;
    procedure Compressed;
    procedure Encrypted;
    procedure WriteAndReadBackSomeChunks;
    procedure WriteAndReadBackSomeChunksTryBoundaries;
    procedure StressWriteReads;
  end;

implementation

uses
  SysUtils, Classes, MongoBson;

const
  HELLO: UTF8String = 'hello world';
  TEST_DATA: UTF8String = 'test read file';
  FEW_BYTES_OF_DATA: UTF8String = 'this is just a few bytes of data';

{ TestMongoGridfsFile }

procedure TestMongoGridfsFile.Check_Write_Read(AWriteFlags, AReadFlags: TMongoFlags;
  ASize: NativeUint);
const
  FILENAME = 'test';
  PASS = '111111';
var
  i, Count : Integer;
  Data, Buffer, p : Pointer;
begin
  FGridfs.RemoveFile(FILENAME);

  Count := ASize;

  GetMem(Data, Count);
  try
    GetMem(Buffer, Count);
    try
      p := Data;
      for i := 1 to Count div Length(FEW_BYTES_OF_DATA) do
      begin
        Move(PAnsiChar(FEW_BYTES_OF_DATA)^, p^, Length(FEW_BYTES_OF_DATA));
        Inc(PByte(p), Length(FEW_BYTES_OF_DATA));
      end;

      FFile := FGridfs.CreateFile(FILENAME, AWriteFlags);
      if mfEncrypt in AWriteFlags then
        FFile.Password := PASS;
      CheckEquals(Count, FFile.Write(PByte(Data)^, Count));
      FFile.Save;

      FFile := FGridfs.FindFile(FILENAME, AReadFlags);
      if mfDecrypt in AReadFlags then
        FFile.Password := PASS;
      CheckEquals(Count, FFile.Read(Buffer^, Count));
      Check(CompareMem(Buffer, Data, Count));
    finally
      FreeMem(Buffer);
    end;
  finally
    FreeMem(Data);
  end;
end;

procedure TestMongoGridfsFile.Compressed;
const
  FILENAME = 'test';
begin
  FFile := FGridfs.CreateFile(FILENAME, [mfCompress]);
  CheckFalse(FFile.Compressed);
  CheckEquals(Length(TEST_DATA), FFile.Write(TEST_DATA[1], Length(TEST_DATA)));
  CheckEquals(Length(TEST_DATA), FFile.Write(TEST_DATA[1], Length(TEST_DATA)));
  FFile.Save;

  FFile := FGridfs.FindFile(FILENAME, [mfUncompress]);
  Check(FFile.Compressed);
  Check(FFile.CompressedSize < FFile.Size);
  CheckEquals(2 * Length(TEST_DATA), FFile.Read(FBuf, SizeOf(FBuf)));
  Check(CompareMem(PAnsiChar(TEST_DATA), @FBuf, Length(TEST_DATA)));
  Check(CompareMem(PAnsiChar(TEST_DATA), @FBuf[Length(TEST_DATA)], Length(TEST_DATA)));
end;

procedure TestMongoGridfsFile.Encrypted;
const
  FILENAME = 'test';
  PASS = '111111';
begin
  FFile := FGridfs.CreateFile(FILENAME, [mfEncrypt]);
  CheckFalse(FFile.Encrypted);
  FFile.Password := PASS;
  CheckEquals(Length(TEST_DATA), FFile.Write(TEST_DATA[1], Length(TEST_DATA)));
  FFile.Save;

  FFile := FGridfs.FindFile(FILENAME, [mfDecrypt]);
  Check(FFile.Encrypted);
  FFile.Password := PASS;
  CheckEquals(Length(TEST_DATA), FFile.Read(FBuf, SizeOf(FBuf)));
  Check(CompareMem(PAnsiChar(TEST_DATA), @FBuf, Length(TEST_DATA)));
end;

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
  CheckEquals(11, FFile.Position);
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
  Check(CompareMem(@TEST_DATA[6], @FBuf, 9));
end;

procedure TestMongoGridfsFile.SeekEnd;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := FGridfs.FindFile;
  FFile.Seek(-3, soEnd);
  CheckEquals(4, FFile.Read(FBuf, SizeOf(FBuf)));
  Check(CompareMem(@TEST_DATA[11], @FBuf, 4));
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

procedure TestMongoGridfsFile.Size;
begin
  FFile := FGridfs.CreateFile('test');
  FFile.Write(PByte(FEW_BYTES_OF_DATA), Length(FEW_BYTES_OF_DATA));
  CheckEquals(Length(FEW_BYTES_OF_DATA), FFile.Size);
end;

procedure TestMongoGridfsFile.StressWriteReads;
const
  FILESIZE = 512 * 1024;
  RE_WRITE_POS : array [0..5] of integer = (1024, 1024 * 128, 523, 1024 * 256 + 33, 0, 1024 * 100 + 65);
  RE_WRITE_LEN : array [0..5] of integer = ( 512, 1024 * 300, 1024 * 128, 45, 1024 * 64 + 5, 1024 * 313);
var
  Buffer : PAnsiChar;
  i, j : integer;
  ReadBuf : PAnsiChar;
begin
  FFile := FGridfs.CreateFile('test');
  GetMem(Buffer, FILESIZE);
  try
    GetMem(ReadBuf, FILESIZE);
    try
      for i := 0 to FILESIZE - 1 do
        Buffer[i] := AnsiChar(Random(256));
      CheckEquals(FILESIZE, FFile.Write(Buffer^, FILESIZE), 'Call to Write should have written all data requested');
      FFile.Save;

      FFile := FGridfs.FindFile; // Reopen the file
      for i := Low(RE_WRITE_POS) to High(RE_WRITE_POS) do
        begin
          FFile.Seek(RE_WRITE_POS[i], soBeginning);
          for j := RE_WRITE_POS[i] to RE_WRITE_POS[i] + RE_WRITE_LEN[i] do
            Buffer[j] := AnsiChar(Random(256));
          CheckEquals(RE_WRITE_LEN[i], FFile.Write(Buffer[RE_WRITE_POS[i]], RE_WRITE_LEN[i]), 'Amount of data overriden don''t match count');
          FFile.Save;
          FFile.Seek(RE_WRITE_POS[i], soBeginning);
          CheckEquals(RE_WRITE_LEN[i], FFile.Read(ReadBuf^, RE_WRITE_LEN[i]), 'Amount of data read after overriding don''t match');
          Check(CompareMem(@Buffer[RE_WRITE_POS[i]], ReadBuf, RE_WRITE_LEN[i]), 'Data read from stream don''t match data written');
        end;
    finally
      FreeMem(ReadBuf);
    end;
  finally
    FreeMem(Buffer);
  end;
end;

procedure TestMongoGridfsFile.Write;
begin
  FFile := FGridfs.CreateFile('test_write');
  CheckEquals(11, FFile.Write(HELLO[1], Length(HELLO)));
  FFile.Save;

  FFile := FGridfs.FindFile;
  CheckEquals(11, FFile.Size);
end;

procedure TestMongoGridfsFile.WriteAndReadBackSomeChunks;
const
  BufSize = 1024 * 1024;
  ReadStart = 123;
  ReadReduction = 123 * 2;
var
  ReturnValue: Integer;
  Buffer, Buffer2: PAnsiChar;
  i : integer;
begin
  FFile := FGridfs.CreateFile('test_write');
  GetMem(Buffer, BufSize + 1);
  try
    Buffer[BufSize] := #0;
    for i := 0 to BufSize - 1 do
      if (i + 1) mod 128 <> 0 then
        Buffer[i] := AnsiChar(Random(29) + ord('A'))
      else Buffer[i] := #13;
    ReturnValue := FFile.Write(Buffer^, BufSize - 1);
    CheckEquals(BufSize - 1, ReturnValue, 'Write didn''t return that I wrote the same amount of bytes written');
    FFile.Seek(ReadStart, soBeginning);
    Buffer[ReadStart] := 'Z';
    Buffer[ReadStart + 1] := 'A';
    Buffer[ReadStart + 2] := 'P';
    FFile.Write(Buffer[ReadStart], 3);
    FFile.save;
    FFile.Seek(ReadStart, soBeginning);
    GetMem(Buffer2, BufSize + 1);
    try
      Buffer2[BufSize - ReadStart - ReadReduction] := #0;
      FFile.Read(Buffer2^, BufSize - ReadReduction - ReadStart);
      CheckEqualsString(copy(string(PAnsiChar(@Buffer[ReadStart])), 1, BufSize - ReadReduction - ReadStart),
                        string(PAnsiChar(Buffer2)), 'String read after writing didn''t match');
    finally
      FreeMem(Buffer2);
    end;
  finally
    FreeMem(Buffer);
  end;
end;

procedure TestMongoGridfsFile.WriteAndReadBackSomeChunksTryBoundaries;
const
  BufSize = 1024 * 1024;
  ReadStart = 123;
  ReadReduction = 123 * 2;
var
  ReturnValue: Integer;
  Buffer, Buffer2: PAnsiChar;
  i : integer;
begin
  FFile := FGridfs.CreateFile('test_write');
  GetMem(Buffer, BufSize + 1);
  try
    Buffer[BufSize] := #0;
    for i := 0 to BufSize - 1 do
      if (i + 1) mod 128 <> 0 then
        Buffer[i] := AnsiChar(Random(29) + ord('A'))
      else Buffer[i] := #13;
    ReturnValue := FFile.Write(Buffer^, BufSize - 1);
    CheckEquals(BufSize - 1, ReturnValue, 'Write didn''t return that I wrote the same amount of bytes written');
    FFile.Seek(ReadStart, soBeginning);
    Buffer[ReadStart] := 'Z';
    Buffer[ReadStart + 1] := 'A';
    Buffer[ReadStart + 2] := 'P';
    Buffer[256 * 1024 - 1] := '+';
    FFile.Write(Buffer[ReadStart], 3);
    FFile.Seek(256 * 1024 - 1, soBeginning);
    FFile.Write(Buffer[256 * 1024 - 1], 1);
    FFile.Seek(ReadStart, soBeginning);
    FFile.Write(Buffer[ReadStart], 3);
    FFile.Seek(256 * 1024, soBeginning);
    FFile.Seek(ReadStart, soBeginning);
    GetMem(Buffer2, BufSize + 1);
    try
      Buffer2[BufSize - ReadStart - ReadReduction] := #0;
      FFile.Read(Buffer2^, BufSize - ReadReduction - ReadStart);
      CheckEqualsString(copy(string(PAnsiChar(@Buffer[ReadStart])), 1, BufSize - ReadReduction - ReadStart),
                             string(PAnsiChar(Buffer2)), 'String read after writing didn''t match');
    finally
      FreeMem(Buffer2);
    end;
  finally
    FreeMem(Buffer);
  end;
end;

procedure TestMongoGridfsFile.Write_Seek_Read;
begin
  FFile := FGridfs.CreateFile('test');
  CheckEquals(11, FFile.Write(HELLO[1], Length(HELLO)));
  FFile.Save;

  FFile.Seek(0, soBeginning);

  CheckEquals(11, FFile.Read(FBuf, SizeOf(FBuf)));
  Check(CompareMem(@HELLO[1], @FBuf, 11));
end;

procedure TestMongoGridfsFile.Write_Read;
const
  SIZES: array[0..2] of Integer = (6, 256 * 1024, 5 * 1024 * 1024);
  FLAGS_SIZE = 4;
  WRITE_FLAGS: array[1..FLAGS_SIZE] of TMongoFlags = ([],
                                                      [mfCompress],
                                                      [mfEncrypt],
                                                      [mfCompress, mfEncrypt]);
  READ_FLAGS: array[1..FLAGS_SIZE] of TMongoFlags = ([],
                                                     [mfUncompress],
                                                     [mfDecrypt],
                                                     [mfUncompress, mfDecrypt]);
var
  i, j: Integer;
begin
  for j := 1 to FLAGS_SIZE do
    for i := Low(SIZES) to High(SIZES) do
      Check_Write_Read(WRITE_FLAGS[j], READ_FLAGS[j], SIZES[i]);
end;

initialization
  RegisterTest(TestMongoGridfsFile.Suite);

end.
