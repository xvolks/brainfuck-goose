# brainfuck-goose

A Brainfuck interpreter written in [Goose](https://github.com/aardappel/goose).

Goose is a memory-safe systems language with no heap allocator, garbage collector, or lifetime annotations. 

> **Note:** The implementation of this interpreter was written by hand.

## Usage

```bash
goose bf.goose -- <source_file.bf>
```

## Compilation

```bash
goose build -O2 bf.goose 
./bf <source_file.bf>
```

## License

MIT
