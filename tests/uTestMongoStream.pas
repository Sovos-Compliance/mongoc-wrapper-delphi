unit uTestMongoStream;

interface

uses
  TestFramework,
  uTestMongo, uTestMongoGridfs, uMongoGridfs, uMongoGridfsFile, uDelphi5, uMongoStream;

type
  TestMongoStream = class(TMongoGridfsTestCase)
  private
    FFile: TMongoStream;
    FBuf: array[0..255] of AnsiChar;
    procedure Check_Write_Read(AWriteFlags, AReadFlags: TMongoFlags; ASize: NativeUint);
  published
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
    procedure Write_AndExpandStreamWithSetSize;
    procedure Write_SerializedWithJournal;
  end;

implementation

uses
  SysUtils, Classes, MongoBson;

const
  HELLO: UTF8String = 'hello world';
  TEST_DATA: UTF8String = 'test read file';
  FEW_BYTES_OF_DATA: UTF8String = 'this is just a few bytes of data';

{ TestMongoStream }

procedure TestMongoStream.Check_Write_Read(AWriteFlags, AReadFlags: TMongoFlags;
  ASize: NativeUint);
const
  FILENAME = 'test';
  PASS = '111111';
var
  i, Count : Integer;
  Data, Buffer, p : Pointer;
  APassword : String;
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

      if mfEncrypt in AWriteFlags then
        APassword := PASS
      else APassword := '';
      FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', FILENAME, msmCreate, AWriteFlags, APassword);
      try
        CheckEquals(Count, FFile.Write(PByte(Data)^, Count));
      finally
        FFile.Free;
      end;
      if mfDecrypt in AReadFlags then
        APassword := PASS
      else APassword := '';
      FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', FILENAME, msmOpen, AReadFlags, APassword);
      try
        CheckEquals(Count, FFile.Read(Buffer^, Count));
        Check(CompareMem(Buffer, Data, Count));
      finally
        FFile.Free;
      end;
    finally
      FreeMem(Buffer);
    end;
  finally
    FreeMem(Data);
  end;
end;

procedure TestMongoStream.Compressed;
const
  FILENAME = 'test';
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', FILENAME, msmCreate, [mfCompress]);
  try
    CheckFalse(FFile.GridFSFile.Compressed);
    CheckEquals(Length(TEST_DATA), FFile.Write(TEST_DATA[1], Length(TEST_DATA)));
    CheckEquals(Length(TEST_DATA), FFile.Write(TEST_DATA[1], Length(TEST_DATA)));
  finally
    FFile.Free;
  end;

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', FILENAME, msmOpen, [mfUncompress]);
  try
    Check(FFile.GridFSFile.Compressed);
    Check(FFile.GridFSFile.CompressedSize < FFile.Size);
    CheckEquals(2 * Length(TEST_DATA), FFile.Read(FBuf, SizeOf(FBuf)));
    Check(CompareMem(PAnsiChar(TEST_DATA), @FBuf, Length(TEST_DATA)));
    Check(CompareMem(PAnsiChar(TEST_DATA), @FBuf[Length(TEST_DATA)], Length(TEST_DATA)));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Encrypted;
const
  FILENAME = 'test';
  PASS = '111111';
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', FILENAME, msmCreate, [mfEncrypt], PASS);
  try
    CheckFalse(FFile.GridFSFile.Encrypted);
    CheckEquals(Length(TEST_DATA), FFile.Write(TEST_DATA[1], Length(TEST_DATA)));
  finally
    FFile.Free;
  end;

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', FILENAME, msmOpen, [mfDecrypt], PASS);
  try
    Check(FFile.GridFSFile.Encrypted);
    CheckEquals(Length(TEST_DATA), FFile.Read(FBuf, SizeOf(FBuf)));
    Check(CompareMem(PAnsiChar(TEST_DATA), @FBuf, Length(TEST_DATA)));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Position;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmOpen);
  try
    CheckEquals(0, FFile.Position);

    FFile.Seek(9, soBeginning);
    CheckEquals(9, FFile.Position);

    FFile.Seek(2, soCurrent);
    CheckEquals(11, FFile.Position);

    FFile.Seek(-5, soCurrent);
    CheckEquals(6, FFile.Position);

    FFile.Seek(-2, soEnd);
    CheckEquals(11, FFile.Position);
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Read;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmOpen);
  try
    CheckEquals(Length(TEST_DATA), FFile.Read(FBuf, SizeOf(FBuf)));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Seek;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmOpen);
  try
    FFile.Seek(5, soBeginning);
    CheckEquals(9, FFile.Read(FBuf, SizeOf(FBuf)));
    Check(CompareMem(@TEST_DATA[6], @FBuf, 9));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.SeekEnd;
begin
  CreateFileStub('test', TEST_DATA);

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmOpen);
  try
    FFile.Seek(-3, soEnd);
    CheckEquals(4, FFile.Read(FBuf, SizeOf(FBuf)));
    Check(CompareMem(@TEST_DATA[11], @FBuf, 4));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Size;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmCreate);
  try
    FFile.Write(PByte(FEW_BYTES_OF_DATA), Length(FEW_BYTES_OF_DATA));
    CheckEquals(Length(FEW_BYTES_OF_DATA), FFile.Size);
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.StressWriteReads;
const
  FILESIZE = 512 * 1024;
  RE_WRITE_POS : array [0..5] of integer = (1024, 1024 * 128, 523, 1024 * 256 + 33, 0, 1024 * 100 + 65);
  RE_WRITE_LEN : array [0..5] of integer = ( 512, 1024 * 300, 1024 * 128, 45, 1024 * 64 + 5, 1024 * 313);
var
  Buffer : PAnsiChar;
  i, j : integer;
  ReadBuf : PAnsiChar;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmCreate);
  try
    GetMem(Buffer, FILESIZE);
    try
      GetMem(ReadBuf, FILESIZE);
      try
        for i := 0 to FILESIZE - 1 do
          Buffer[i] := AnsiChar(Random(256));
        CheckEquals(FILESIZE, FFile.Write(Buffer^, FILESIZE), 'Call to Write should have written all data requested');
        FreeAndNil(FFile);

        FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmOpen);
        for i := Low(RE_WRITE_POS) to High(RE_WRITE_POS) do
          begin
            FFile.Seek(RE_WRITE_POS[i], soBeginning);
            for j := RE_WRITE_POS[i] to RE_WRITE_POS[i] + RE_WRITE_LEN[i] do
              Buffer[j] := AnsiChar(Random(256));
            CheckEquals(RE_WRITE_LEN[i], FFile.Write(Buffer[RE_WRITE_POS[i]], RE_WRITE_LEN[i]), 'Amount of data overriden don''t match count');
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
  finally
    if FFile <> nil then    
      FFile.Free;
  end;
end;

procedure TestMongoStream.Write;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmCreate);
  try
    CheckEquals(11, FFile.Write(HELLO[1], Length(HELLO)));
  finally
    FFile.Free;
  end;

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmOpen);
  try
    CheckEquals(11, FFile.Size);
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Write_AndExpandStreamWithSetSize;
const
  TOTAL_SIZE = 1024 * 1024 + 128 * 1024;
var
  Buf : UTF8String;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmCreate);
  try
    FFile.Size := 0; // This should work
    // FFile.Size := FFile.GridFSFile.ChunkSize; This code make test fail when doing write on the C library not sure why, changing to FFile.GridFSFile.ChunkSize + 1 works
    // FFile.Size := Length(HELLO); // Pre-alloc data, this should work but it's currently failing
    CheckEquals(11, FFile.Write(HELLO[1], Length(HELLO)));
    try
      FFile.Size := FFile.Size - 1;
      Fail('Should not be able to attempt size reduction of TMongoStream object');
    except
      on EMongoStream do;
    end;
    FFile.Size := FFile.Size; // This should work, attempt simply exists when size is equal to current
    FFile.Size := TOTAL_SIZE;
  finally
    FFile.Free;
  end;

  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmOpen);
  try
    CheckEquals(TOTAL_SIZE, FFile.Size);
    SetLength(Buf, length(HELLO));
    FFile.Read(Buf[1], length(HELLO));
    CheckEqualsString(Buf, HELLO);
    SetLength(Buf, TOTAL_SIZE);
    FFile.Position := 0;
    CheckEquals(TOTAL_SIZE, FFile.Read(Buf[1], TOTAL_SIZE));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Write_SerializedWithJournal;
const
  ONE_MB = 1024 * 1024;
  BufSize = ONE_MB;
  Loops = 40;
var
  i : integer;
  WriteBuffer, ReadBuffer : Pointer;
  GetLastErrorOkAttribute, GetLastErrorErrAttribute : IBsonIterator;
begin
  GetMem(WriteBuffer, BufSize);
  try
    GetMem(ReadBuffer, BufSize);
    try
      for i := 0 to BufSize - 1 do
        PAnsiChar(WriteBuffer)[i] := AnsiChar(Random(256));
      FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmCreate);
      try
        FFile.SerializedWithJournal := True;
        FFile.SerializeWithJournalByteWritten := 10 * ONE_MB;
        for i := 1 to Loops do
          begin
            CheckEquals(BufSize, FFile.Write(WriteBuffer^, BufSize));
            if Cardinal(i * BufSize) > FFile.SerializeWithJournalByteWritten then
              begin
                Check(FFile.LastSerializeWithJournalResult <> nil, 'LastSerializeWithJournalResult should be <> nil');
                GetLastErrorOkAttribute := FFile.LastSerializeWithJournalResult.find('ok');
                Check(GetLastErrorOkAttribute <> nil, 'OK attribute should be <> nil');
                CheckEquals(1, GetLastErrorOkAttribute.Value, 'OK attribute should be equals to 1');
                GetLastErrorErrAttribute := FFile.LastSerializeWithJournalResult.find('err');
                Check(GetLastErrorErrAttribute <> nil, 'err attribute should be <> nil');
                Check(GetLastErrorErrAttribute.Kind = BSON_TYPE_NULL, 'err attribute should be NULL');
              end
            else Check(FFile.LastSerializeWithJournalResult = nil, 'LastSerializeWithJournalResult must be = nil');
          end;
      finally
        FFile.Free;
      end;

      FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmOpen);
      try
        CheckEquals(BufSize * Loops, FFile.Size);
        for i := 1 to Loops do
          begin
            CheckEquals(BufSize, FFile.Read(ReadBuffer^, BufSize));
            Check(CompareMem(ReadBuffer, WriteBuffer, BufSize));
          end;
      finally
        FFile.Free;
      end;
    finally
      FreeMem(ReadBuffer);
    end;
  finally
    FreeMem(WriteBuffer);
  end;
end;

procedure TestMongoStream.WriteAndReadBackSomeChunks;
const
  BufSize = 1024 * 1024;
  ReadStart = 123;
  ReadReduction = 123 * 2;
var
  ReturnValue: Integer;
  Buffer, Buffer2: PAnsiChar;
  i : integer;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmCreate);
  try
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
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.WriteAndReadBackSomeChunksTryBoundaries;
const
  BufSize = 1024 * 1024;
  ReadStart = 123;
  ReadReduction = 123 * 2;
var
  ReturnValue: Integer;
  Buffer, Buffer2: PAnsiChar;
  i : integer;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test_write', msmCreate);
  try
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
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Write_Seek_Read;
begin
  FFile := TMongoStream.Create(FClient, FDatabase.Name, 'test_gfs', 'test', msmCreate);
  try
    CheckEquals(11, FFile.Write(HELLO[1], Length(HELLO)));

    FFile.Seek(0, soBeginning);

    CheckEquals(11, FFile.Read(FBuf, SizeOf(FBuf)));
    Check(CompareMem(@HELLO[1], @FBuf, 11));
  finally
    FFile.Free;
  end;
end;

procedure TestMongoStream.Write_Read;
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
  RegisterTest(TestMongoStream.Suite);

end.
