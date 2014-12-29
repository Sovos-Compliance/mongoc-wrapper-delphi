unit uTestMongoCollection;

interface

uses
  TestFramework,
  uTestMongo,
  uMongoClient, uMongoCollection;

const
  TEST_COLLECTION = 'test';

type
  TestMongoCollection = class(TMongoTestCase)
  private
    FColl: TMongoCollection;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure RunCommand;
    procedure GetCount;
    procedure CreateIndex;
    procedure DropIndex;
    procedure Drop;
    procedure Insert;
    procedure FindAndModify;
    procedure FindAndModifyRemove;
    procedure Remove;
    procedure Rename;
    procedure Save;
    procedure GetStats;
    procedure Update;
  end;

implementation

uses
  MongoBson, Variants, uDelphi5;

{ TestMongoCollection }

procedure TestMongoCollection.CreateIndex;
const
  idxName = 'idx1';
  idx: array[0..1] of UTF8String = ('field1', 'field2');
  expectedMsg = 'Index with name: ' + idxName + ' already exists with different options';
begin
  FColl.CreateIndex(idx, idxName, true);
  Check(FColl.GetStats().find('indexSizes.' + idxName) <> nil);

  try
    FColl.CreateIndex(idx, idxName);
    Fail('EMongoCollection expected');
  except
    on e: EMongoCollection do
      CheckEqualsString(expectedMsg, e.Message);
  end;
end;

procedure TestMongoCollection.Drop;
begin
  // collection created only when some documend inserted
  CheckFalse(FDatabase.HasCollection(FColl.Name));

  try
    FColl.Drop;
    Fail('EMongoCollection expected');
  except
    on e: EMongoCollection do
      CheckEqualsString('ns not found', e.Message);
  end;
end;

procedure TestMongoCollection.DropIndex;
const
  idxName = 'idx1';
  idx: array[0..0] of UTF8String = ('field1');
begin
  FColl.CreateIndex(idx, idxName);
  FColl.DropIndex(idxName);

  Check(FColl.GetStats().find('indexSizes.' + idxName) = nil);
end;

procedure TestMongoCollection.FindAndModify;
var
  it: IBsonIterator;
begin
  it := FColl.FindAndModify(BSON(['a', 1]),
                            BSON(['$set', '{', 'a', 2, '}'])).find('value');
  Check(it.Kind = BSON_TYPE_NULL);
  Check(VarIsNull(it.Value));

  FColl.Insert(BSON(['name', 'Bill', 'age', 17]));
  it := FColl.FindAndModify(BSON(['name', 'Bill']),
                            BSON(['$set', '{', 'age', 18, '}'])).find('value.age');
  Check(it <> nil);
  CheckEquals(17, it.AsInteger);
end;

procedure TestMongoCollection.FindAndModifyRemove;
const
  sort: array[0..0] of UTF8String = ('priority');
  fields: array[0..0] of UTF8String = ('_id');
var
  it: IBsonIterator;
begin
  FColl.Insert(BSON(['should_remove', true, 'priority', 1]));
  FColl.Insert(BSON(['should_remove', true, 'priority', 2]));
  it := FColl.FindAndModifyRemove(BSON(['should_remove', true]),
                                  sort, fields).find('value').subiterator;
  Check(it.next);
  CheckEqualsString('_id', string(it.key));
  CheckFalse(it.next); // single field should be fetched
end;

procedure TestMongoCollection.GetCount;
begin
  CheckEquals(0, FColl.GetCount);

  FColl.Insert(BSON(['a', 1]));
  CheckEquals(1, FColl.GetCount);
  CheckEquals(0, FColl.GetCount(BSON(['a', '{', '$lt', 1, '}'])));
  CheckEquals(0, FColl.GetCount(nil, 1));
end;

procedure TestMongoCollection.GetStats;
var
  it: IBsonIterator;
begin
  FColl.Insert(BSON(['just_to_force_collection_creation', 1]));

  it := FColl.GetStats.iterator;
  Check(it.next);
  CheckEqualsString('ns', string(it.key));
  Check(it.next);
  CheckEqualsString('count', string(it.key));
  Check(it.next);
  CheckEqualsString('size', string(it.key));
end;

procedure TestMongoCollection.Insert;
begin
  CheckEquals(0, FColl.GetCount);
  FColl.Insert(BSON(['a', 1]));
  CheckEquals(1, FColl.GetCount);
end;

procedure TestMongoCollection.Remove;
begin
  FColl.Insert(BSON(['del', true]));
  FColl.Insert(BSON(['del', true]));
  FColl.Insert(BSON(['del', false]));
  CheckEquals(3, FColl.GetCount);

  FColl.Remove(BSON(['del', true]));
  CheckEquals(1, FColl.GetCount);
end;

procedure TestMongoCollection.Rename;
const
  NEW_NAME = 'renamed';
begin
  if FDatabase.HasCollection(NEW_NAME) then
    FDatabase.RunCommand(BSON(['drop', NEW_NAME]));

  FColl.Insert(BSON(['just_to_force_collection_creation', 1]));

  FColl.Rename(NEW_NAME);
  CheckEqualsString(NEW_NAME, string(FColl.Name));
end;

procedure TestMongoCollection.RunCommand;
var
  it: IBsonIterator;
begin
  it := FColl.RunCommand(BSON(['getLastError', 1])).iterator;
  Check(it.next);
  CheckEqualsString('connectionId', string(it.key));
  Check(it.Find('err'));
end;

procedure TestMongoCollection.SetUp;
begin
  inherited;
  FColl := FClient.GetCollection(TEST_DB, TEST_COLLECTION);
  CheckEqualsString(TEST_COLLECTION, string(FColl.Name));
  if FDatabase.HasCollection(FColl.Name) then
    FColl.Drop;
end;

procedure TestMongoCollection.TearDown;
begin
  FColl.Free;
  inherited;
end;

procedure TestMongoCollection.Update;
begin
  FColl.Insert(BSON(['need_to_upd', true, 'c', 0]));
  FColl.Insert(BSON(['need_to_upd', true, 'c', 0]));
  FColl.Insert(BSON(['need_to_upd', false, 'c', 0]));

  FColl.Update(BSON(['need_to_upd', true]),
               BSON(['$inc', '{', 'c', 1, '}']),
               nil, MONGOC_UPDATE_MULTI_UPDATE);

  CheckEquals(2, FColl.GetCount(BSON(['c', '{', '$gt', 0, '}'])));
end;

procedure TestMongoCollection.Save;
var
  id: IBsonOID;
  buf: IBsonBuffer;
  b: IBson;
  it: IBsonIterator;
begin
  id := NewBsonOID;
  buf := NewBsonBuffer;
  buf.append('_id', id);
  buf.append('field', 1.3);
  b := buf.finish;

  FColl.Save(b);
  buf.append('field2', 0.9);
  FColl.Save(b);

  it := FColl.FindAndModifyRemove(NewBson).find('value').subiterator;
  Check(it.next);
  Check(it.next);
  CheckEquals(1.3, it.AsDouble, DOUBLE_EPSILON);
  Check(it.next);
  CheckEquals(0.9, it.AsDouble, DOUBLE_EPSILON);
end;

initialization
  RegisterTest(TestMongoCollection.Suite);

end.
