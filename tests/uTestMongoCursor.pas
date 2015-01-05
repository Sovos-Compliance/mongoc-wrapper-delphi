unit uTestMongoCursor;

interface

uses
  TestFramework,
  uTestMongo, uMongoCursor;

type
  TestMongoCursor = class(TMongoTestCase)
  private
    FCursor: TMongoCursor;
  published
    procedure Next_Current;
  end;

implementation

uses
  MongoBson, uMongoCollection;

{ TestMongoCursor }

procedure TestMongoCursor.Next_Current;
var
  coll: TMongoCollection;
  it: IBsonIterator;
begin
  coll := FDatabase.GetCollection('test');
  coll.Drop;
  coll.Insert(BSON(['a', 1]));
  coll.Insert(BSON(['b', 2]));

  FCursor := coll.Find;
  Check(FCursor.Current = nil);

  Check(FCursor.Next);
  it := FCursor.Current.iterator;
  Check(it.find('a'));
  CheckEquals(1, it.AsInteger);

  Check(FCursor.Next);
  it := FCursor.Current.iterator;
  Check(it.find('b'));
  CheckEquals(2, it.AsInteger);

  CheckFalse(FCursor.Next);
end;

initialization
  RegisterTest(TestMongoCursor.Suite);

end.
