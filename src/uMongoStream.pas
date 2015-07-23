{
    Copyright 2009-2015 Sovos Compliance, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
}

{ Use the option SerializedWithJournal set to True if you want to synchronize
  write operations with Journal writing to prevent overflowing Mongo database
  memory }

unit uMongoStream;

interface

uses
  Classes, uMongoGridfs, uMongoGridfsFile, uMongoClient, MongoBson, SysUtils;

{$I MongoC_defines.inc}

const
  E_FileNotFound                     = 90300;
  E_FGridFileIsNil                   = 90301;
  E_FailedToCreateFile               = 90302;

  SERIALIZE_WITH_JOURNAL_BYTES_WRITTEN = 1024 * 1024 * 10; (* Serialize with Journal every 10 megs written by default *)

type
  EMongoStream = class(Exception);
  TMongoStreamOpenMode = (msmCreate, msmOpen);
  TMongoStream = class(TStream)
  private
    FGridFS : IMongoGridfs;
    FGridFile : IMongoGridfsFile;
    FMongo: TMongoClient;
    FSerializedWithJournal: Boolean;
    FBytesWritten: Cardinal;
    FDB : UTF8String;
    FLastSerializeWithJournalResult: IBson;
    FSerializeWithJournalByteWritten: Cardinal;
    FChanged: Boolean;
    procedure CheckGridFile;
    procedure CheckSerializeWithJournal; {$IFDEF DELPHI2007} inline; {$ENDIF}
    procedure SerializeWithJournal;
  protected
    function GetSize: {$IFNDEF VER130} Int64; override; {$ELSE}{$IFDEF Enterprise} Int64; override; {$ELSE} Longint; {$ENDIF}{$ENDIF}
    {$IFDEF DELPHI2007}
    procedure SetSize(NewSize: longint); override;
    procedure SetSize(const NewSize: Int64); overload; override;
    procedure SetSize64(const NewSize : Int64);
    {$ELSE}
    procedure SetSize(NewSize: {$IFDef Enterprise} Int64 {$Else} longint {$EndIf}); override;
    {$ENDIF}
  public
    constructor Create(AMongo: TMongoClient; const ADB, AFileName: UTF8String; AMode: TMongoStreamOpenMode; const AFlags: TMongoFlags = []; const AEncryptionPassword: String = ''); overload;
    constructor Create(AMongo: TMongoClient; const ADB, APrefix, AFileName: UTF8String; AMode: TMongoStreamOpenMode; const AFlags: TMongoFlags = []; const AEncryptionPassword: String = ''); overload;
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    {$IFDEF DELPHI2007}
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; overload; override;
    function Seek(Offset: longint; Origin: Word ): longint; override;
    {$ELSE}
    function Seek(Offset: {$IFDef Enterprise} Int64 {$Else} longint {$EndIf}; Origin: {$IFNDEF VER130}TSeekOrigin{$Else}{$IFDef Enterprise}TSeekOrigin{$ELSE}Word{$ENDIF}{$ENDIF}): {$IFDef Enterprise} Int64 {$Else} longint {$EndIf}; override;
    {$ENDIF}
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure Flush;

    property GridFS : IMongoGridfs read FGridFS;
    property GridFSFile : IMongoGridfsFile read FGridFile;
    property LastSerializeWithJournalResult: IBson read FLastSerializeWithJournalResult;
    property Mongo: TMongoClient read FMongo;
    property SerializedWithJournal: Boolean read FSerializedWithJournal write FSerializedWithJournal default False;
    property SerializeWithJournalByteWritten : Cardinal read FSerializeWithJournalByteWritten write FSerializeWithJournalByteWritten default SERIALIZE_WITH_JOURNAL_BYTES_WRITTEN;
    property Size: {$IFNDEF VER130}Int64 {$ELSE}{$IFDef Enterprise}Int64 {$ELSE}Longint{$ENDIF}{$ENDIF} read GetSize write {$IFDEF DELPHI2007}SetSize64{$ELSE}SetSize{$ENDIF};
  end;

implementation

uses
  uMongo;

const
  SFs = 'fs';
  GET_LAST_ERROR_CMD = 'getLastError';
  WAIT_FOR_JOURNAL_OPTION = 'j';

resourcestring
  SFailedToCreateFile = 'Failed to create file %s (D%d)';
  SSettingGridFSFileSizeNotSupported = 'Setting GridFS file size not supported';
  SFileNotFound = 'File %s not found (D%d)';
  SFGridFileIsNil = 'FGridFile is nil (D%d)';
  SFGridFSIsNil = 'FGridFS is nil (D%d)';
  SStreamNotCreatedForWriting = 'Stream not created for writing (D%d)';
  SStatusMustBeOKInOrderToAllowStre = 'Status must be OK in order to allow stream read operations (D%d)';
  SFailedInitializingEncryptionKey = 'Failed initializing encryption key (D%d)';

constructor TMongoStream.Create(AMongo: TMongoClient; const ADB, AFileName: UTF8String;
                                AMode: TMongoStreamOpenMode; const AFlags: TMongoFlags = [];
                                const AEncryptionPassword: String = '');
begin
  Create(AMongo, ADB, SFs, AFileName, AMode, AFlags, AEncryptionPassword);
end;

constructor TMongoStream.Create(AMongo: TMongoClient; const ADB, APrefix, AFileName: UTF8String;
                                AMode: TMongoStreamOpenMode; const AFlags: TMongoFlags = [];
                                const AEncryptionPassword: String = '');
begin
  inherited Create;
  FSerializeWithJournalByteWritten := SERIALIZE_WITH_JOURNAL_BYTES_WRITTEN;
  FDB := ADB;
  FMongo := AMongo;
  FGridFS := AMongo.GetGridfs(FDB, APrefix);
  if msmCreate = AMode then
    begin
      FGridFS.RemoveFile(AFileName);
      FGridFile := FGridFS.CreateFile(AFileName, AFlags);
      if FGridFile = nil then
        raise EMongoStream.CreateFmt(SFailedToCreateFile, [AFileName, E_FailedToCreateFile]);
    end
    else
    begin
      FGridFile := FGridFS.FindFile(AFileName, AFlags);
      if FGridFile = nil then
        raise EMongoStream.CreateFmt(SFileNotFound, [AFileName, E_FileNotFound]);
    end;
  if AEncryptionPassword <> '' then
    FGridFile.Password := AEncryptionPassword;
end;

destructor TMongoStream.Destroy;
begin
  Flush;
  FGridFile := nil;
  FGridFS := nil;
  inherited;
end;

procedure TMongoStream.CheckGridFile;
begin
  if FGridFile = nil then
    raise EMongoStream.CreateFmt(SFGridFileIsNil, [E_FGridFileIsNil]);
end;

function TMongoStream.GetSize: {$IFNDEF VER130}Int64{$ELSE}{$IFDef Enterprise}Int64{$ELSE}Longint{$ENDIF}{$ENDIF};
begin
  CheckGridFile;
  Result := FGridFile.Size;
end;

function TMongoStream.Read(var Buffer; Count: Longint): Longint;
begin
  CheckGridFile;
  Flush;
  Result := FGridFile.Read(Buffer, Count);
end;

{$IFDEF DELPHI2007}
function TMongoStream.Seek(Offset: longint; Origin: Word ): longint;
{$ELSE}
function TMongoStream.Seek(Offset: {$IFDef Enterprise} Int64 {$Else} longint {$EndIf}; Origin: {$IFNDEF VER130}TSeekOrigin{$Else}{$IFDef Enterprise}TSeekOrigin{$ELSE}Word{$ENDIF}{$ENDIF}): {$IFDef Enterprise} Int64 {$Else} longint {$EndIf};
{$ENDIF}
begin
  CheckGridFile;
  Flush;
  FGridFile.Seek(Offset, TSeekOrigin(Origin));
  Result := FGridFile.Position;
end;

{$IFDEF DELPHI2007}
function TMongoStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  CheckGridFile;
  Flush;
  FGridFile.Seek(Offset, Origin);
  Result := FGridFile.Position;
end;
{$ENDIF}

{$IFDEF DELPHI2007}
procedure TMongoStream.SetSize(NewSize: longint);
{$ELSE}
procedure TMongoStream.SetSize(NewSize: {$IFDef Enterprise} Int64 {$Else} longint {$EndIf});
{$ENDIF}
begin
  raise EMongoStream.Create(SSettingGridFSFileSizeNotSupported);
end;

{$IFDEF DELPHI2007}
procedure TMongoStream.SetSize(const NewSize: Int64);
begin
  raise EMongoStream.Create(SSettingGridFSFileSizeNotSupported);
end;
{$ENDIF}

procedure TMongoStream.SerializeWithJournal;
var
  Cmd : IBson;
begin
  (* This command will cause Mongo database to wait until Journal file is written before returning *)
  Cmd := BSON([GET_LAST_ERROR_CMD, 1, WAIT_FOR_JOURNAL_OPTION, 1]);
  FLastSerializeWithJournalResult := FMongo.RunCommand(FDB, Cmd, nil);
end;

procedure TMongoStream.CheckSerializeWithJournal;
begin
  if FSerializedWithJournal and (FBytesWritten > FSerializeWithJournalByteWritten) then
    begin
      FBytesWritten := 0;
      SerializeWithJournal;
    end;
end;

procedure TMongoStream.Flush;
begin
  if not FChanged then
    exit;
  FGridFile.Save;
  FChanged := False;
end;

{$IFDEF DELPHI2007}
procedure TMongoStream.SetSize64(const NewSize : Int64);
begin
  SetSize(NewSize);
end;
{$ENDIF}

function TMongoStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FGridFile.Write(Buffer, Count);
  inc(FBytesWritten, Result);
  CheckSerializeWithJournal;
  FChanged := Result > 0;
end;

end.
