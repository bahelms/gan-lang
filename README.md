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
Locations where types must be explicit (no inference):
  * Function definitions (parameters and returns)

#### Generics
Yes :D

#### Modules
A module is defined by the file in which code lives. Thus `./hello.gan` is the `hello` 
module and `hello` cannot be bound again while the module is in scope.  
`import hello` brings the module into scope.

#### Expressions
* Everything is an expression. The last expression evaluated is the return value.
* There is no `null` value. `Option` type enum of `Some` or `None` instead.
* Matches must be exhaustive.
* All iteration is lazy by default (ala Haskell)

All bindings are private by default. Use `pub` keyword in order for them to be used externally.

#### Code Examples
In the `/examples` directory.

#### Compiler errors/warnings
Warnings:
  * Unused variable/parameter


### Tooling
#### Execution
`$ gan` - start REPL  
`$ gan run` - build and run program without generating artifacts  
`$ gan help` - help page
#### Building 
`$ gan check` - check for successful build without generating artifacts  
`$ gan build` - compile program and all dependencies in debug mode and generate artifacts  
`$ gan build --release` - compile program and all dependencies in release mode, with optimizations  
`$ gan clean` - remove all build artifacts  
#### Testing
`$ gan test`
* Successful tests capture stdout
* Failed tests show stdout

`$ gan bench` - run benchmarks

