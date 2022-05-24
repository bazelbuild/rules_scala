# Current state of Dependency Analyzer for Scala 3

TODOs:
- [x] Plugin option parsing
- [x] Use dependency analyzer in tests
- [x] Report issues found by Dependency Analyzer
- [x] Unused dependency resolution
- [ ] Strict dependency resolution. Code can possibly be minor changes from v2. 
- [ ] High level jar finder
- [ ] AST jar finder
- [ ] Plug in at correct stage in compilation. Currently it runs between Pickler and Staging stages,
which is just copied from plugin example, which may be ok or may be wrong.


Some documentation I found useful: 
- https://dotty.epfl.ch/docs/reference/changed-features/compiler-plugins.html
- https://dotty.epfl.ch/docs/internals/dotty-internals-1-notes.html
- https://javadoc.io/doc/org.scala-lang/scala3-compiler_3/3.1.0/dotty/tools/dotc/core/Denotations$.html