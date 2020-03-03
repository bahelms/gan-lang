# Gan

A functional language that was created for shits and giggles.

Influences:
  - Python:
    * module and import system
    * whitespace delimiting
    * map/dictionary
  - Elixir:
    * pattern matching
    * function signature matching
    * module scope access
  - Scala:
    * val keyword
  - ReasonML:
    * pipeline operator
  - OCaml:
    * case/match statement
  - Go:
    * type annotation syntax
  - Rust:
    * structs
    * public/private identifiers
    * tuples

#### Types
Statically and strongly typed. However, types will be inferred. 

#### Modules
A module is defined by the file in which code lives. Thus `./hello.gan` is the `hello` 
module and `hello` cannot be bound again while the module is in scope.  

#### Expressions
* Everything is an expression. The last expression evaluated is the return value.
* There is no `null` value. `Option` type enum of `Some` or `None` instead.
* Matches must be exhaustive.

All bindings are private by default. Use `pub` keyword in order for them to be used externally.

#### Code Examples


```
# ./main.gan

val x = 5 / 3                     => 1.66667
val y int = 42 + 6                => 48
pub val truthy? = true and false  => false
val list []int = [1, 2, 3]        => [1, 2, 3]
pub val myConst str = "WHAT?"     => "WHAT?"

fn sayHello(name str):
  log("Hello #{name}")  # log is builtin or stdlib

pub fn sideEffect:  # definition parens not needed with no params
  log("hey")

pub fn addOne(num int) int:  # public function
  num + 1

fn addAgain(n int, callback fn(int) int) int:
  log("hey")
  callback(n)

addAgain(5, addOne)
pub val addFive: fn(int) int = addAgain(5)  
addFive(addOne)

fn multiply(num int, callback fn(int, int) int) int:
  callback(num * other, 3)

# Bound anonymous funcs
val add: fn(int, int) int, str = fn(x, y int) int, str: 
  x + y, "hey"
  # Or inferred
val add = fn(x, y int) int, str: 
  x + y, "hey"

if truthy?:
  # stuff
else:
  # stuff

# Pattern matching
val [x, y | rest] = ["a", "b", "c"]             => "a", "b", ["c"]
val [x, y str | rest []str] = ["a", "b", "c"]   => "a", "b", ["c"]

# Pipeline
val num = 
  addOne(5)
  -> multiply(10)
  -> inspect()

addOne(5) -> multiply(10) -> log()

# Linked List
val list []int = [1,2,3]

# Tuple
val myTuple (int, str, bool) = (1, "hey", true)
val myStr = myTuple.1  => "hey"
tuple.0                => 1
tuple.2                => true

# Map
val myMap map[str]int = {"hey": 3, "no": 99}

# match
val what = match my_list:
  [1, x, 4] => x + 3
  [_, x, 3] => 
    log("monkey")
    x * 10
  [2, _, z] =>
    match z:
      42 => 99
      _ => 0
  _ => 0

# match Option
match opt:
  Some(num): 
    num
  None: 0

# Structs
struct User:
  email str
  signin_count int

val user = User(email: "me", signin_count: 2)
val email = "me"
val user = User(email, signin_count: 2)  # if the variable/field are same name

# Enums - they take any type of data
enum IpAddr:
  V4(int, int, int, int)
  V6(str)

val home = IpAdder.V4(127, 0, 0, 1)
val loopback = IpAdder.V6("::1")

fn test(ip IpAdder) IpAdder: ip
```


#### When compiler should complain

* Unused variable/parameter


### Tooling
#### Execution
`$ gan` - start REPL  
`$ gan run` - build and run program without generating artifacts  
#### Building 
`$ gan check` - check for successful build without generating artifacts  
`$ gan build` - compile program and all dependencies in debug mode and generate artifacts  
`$ gan release` - compile program and all dependencies in release mode, with optimizations  
`$ gan clean` - remove all build artifacts  
#### Testing
`$ gan test`
* Successful tests capture stdout
* Failed tests show stdout

`$ gan bench` - run benchmarks

