import eminim, std/[streams, parsejson, enumerate, math]

type
  Foo = ref object
    value: int
    next: Foo
  Fruit = enum
    Apple, Banana, Orange
  Stuff = enum
    NotApple = 1, NotBanana, NotOrange
  Baz = distinct string
  BarBaz = array[2..8, int]
  BarBar = object
    value: Baz
  Bar = ref object
    case kind: Fruit
    of Banana:
      bad: float
      banana: int
    of Apple: apple: string
    else: discard
  Rejected = object
    val: (int,)
  ContentNodeKind = enum
    P, Br, Text
  ContentNode = object
    case kind: ContentNodeKind
    of P: pChildren: seq[ContentNode]
    of Br: discard
    of Text: textStr: string
  BazBat = ref object of RootObj
  BarFoo = ref object of BazBat
    t: float
  BazFoo = ref object of BarFoo
  FooBar = ref object of BazFoo
    x: int
    v: string
  Empty = object
  IrisPlant = object
    sepalLength: float32
    sepalWidth: float32
    petalLength: float32
    petalWidth: float32
    species: string
  Gender = enum
    male, female
  Relation = enum
    biological, step
  Responder = object
    name: string
    gender: Gender
    occupation: string
    age: int
    siblings: seq[Sibling]
  Sibling = object
    sex: Gender
    birth_year: int
    relation: Relation
    alive: bool

#proc storeJson(s: Stream; o: IrisPlant) =
  #s.write "{}"

block:
  let data = ContentNode(kind: P, pChildren: @[
    ContentNode(kind: Text, textStr: "mychild"),
    ContentNode(kind: Br)
  ])
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(ContentNode)
  assert $a == $data
block:
  let data = Bar(kind: Apple, apple: "world")
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(Bar)
  assert a.kind == Apple
  assert a.apple == "world"
block:
  let data = Foo(value: 1, next: Foo(value: 2, next: nil))
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(Foo)
  assert a.value == 1
  let b = a.next
  assert b.value == 2
block:
  let data = [0, 1, 2, 3, 4, 5, 6]
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(BarBaz)
  assert a == data
block:
  let data: array[Fruit, int] = [0, 1, 2]
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(array[Fruit, int])
  assert a == data
block:
  let data = FooBar(v: "hello", t: 1.0)
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(FooBar)
  assert a.v == "hello"
  assert a.t == 1.0
block:
  let s = newStringStream("{}")
  let a = s.jsonTo(Empty)
block:
  let s = newStringStream("""{"x": 42}""")
  let a = s.jsonTo(tuple[x:int])
  assert(a[0] == 42)
block:
  let data = NotApple
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(Stuff)
  assert a == data
block:
  let data = @[
    IrisPlant(sepalLength: 5.1, sepalWidth: 3.5, petalLength: 1.4,
              petalWidth: 0.2, species: "setosa"),
    IrisPlant(sepalLength: 4.9, sepalWidth: 3.0, petalLength: 1.4,
              petalWidth: 0.2, species: "setosa")]
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  for (i, x) in enumerate(jsonItems(s, IrisPlant)):
    if i == 0:
      assert x.species == "setosa"
      assert almostEqual(x.sepalWidth, 3.5'f32)
    else:
      assert almostEqual(x.sepalWidth, 3'f32)
block:
  let data = [
    Responder(name: "John Smith", gender: male, occupation: "student", age: 18,
      siblings: @[Sibling(sex: female, birth_year: 1991, relation: biological, alive: true),
                  Sibling(sex: male, birth_year: 1989, relation: step, alive: true)])]
  var responders: seq[Responder]
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  for x in jsonItems(s, Responder):
    responders.add x
  assert responders.len == 1
  assert responders[0].gender == male
  assert responders[0].siblings.len == 2
block:
  var data: set[Fruit]
  data.incl Apple
  data.incl Orange
  let s = newStringStream()
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(set[Fruit])
  assert(a == data)
#block:
  #proc initFromJson(dst: var Baz; p: var JsonParser) {.borrow.}
  #let s = newStringStream(""" "world" """)
  #let a = s.jsonTo(Baz)
  #assert a.string == "world"
#block:
  #let s = newStringStream("""{"val": {"value": 42}}""")
  #let a = s.jsonTo(Rejected)
  #assert(a.val[0] == 42)
