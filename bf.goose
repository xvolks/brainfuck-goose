/**
 * Basic brainfuck interpreter written in Goose
 */
import os;

const RIBBON_SZ = 3000;

fn fatal(message: const u8[:]) {
    print(message);
    exit(1);
}

fn usage(program: const u8[:], reason: const u8[:]) {
    print(reason);
    print("Usage: ", program, " <Brainfuck source file>");
    exit(1);
}

enum Op {
    Inc,             // Increment current cell content
    Dec,             // Decrement current cell content
    Left,            // Decrement head on the ribbon
    Right,           // Increment head on the ribbon
    Jz {off: i64},   // Jump if zero to matching Jnz
    Jnz{off: i64},   // Jump if not zero to matching Jz
    In,              // Input a character
    Out,             // Print a character
    Nop,             // Any other character is a Nop but not even included in the bytecode.
}

fn parse_op(c: u8) -> Op {
    return match c {
        '+' => { Op.Inc    },
        '-' => { Op.Dec    },
        '<' => { Op.Left   },
        '>' => { Op.Right  },
        '[' => { Op.Jz {0} },
        ']' => { Op.Jnz{0} },
        '.' => { Op.Out    },
        ',' => { Op.In     },
        _   => { Op.Nop    },
    };
}

fn print_s(buffer: u8[>..]&) {
   if buffer.len > 0 {
      write_stdout(buffer);
   }
   buffer.resize(0);
}

fn execute(ops: Op..&[>..]&) {
    var pc = 0;
    var head = 0;
    var mem: u8[RIBBON_SZ] = [0; RIBBON_SZ];
    var i=0;

    var buffer: u8[>..] = [];
    var _in: u8[>..] = [];
    var in_position=0;
    while pc < ops.len {
        let op = ops[pc];
        // if head >= 0 {
        //     print("pc: ", pc, ", head: ", head, ", current: ", mem[head]);
        // } else {
        //     print("pc: ", pc, ", head: ", head);
        // }
        match op {
            Inc     => { mem[head]++; },
            Dec     => { mem[head]--; },
            Left    => { head--; },
            Right   => { head++; },
            Jz off  => { if mem[head] == 0 { pc = off.off; } },
            Jnz off => { if mem[head] != 0 { pc = off.off; } },
            Out     => {
                let c = mem[head];
                buffer.push(c);
                print_s(buffer);
            },
            In      => {
                print_s(buffer);
                if _in.len == 0 {
                  read_stdin(_in);
                  if _in.len == 0 {
                     fatal("Read from stdin returned nothing ?!?")
                  }
                }
                if in_position == _in.len {
                  read_stdin(_in);
                  if in_position == _in.len {
                     // EOF reached?
                     mem[head] = 0;
                  }
                } else {
                  mem[head] = _in[in_position];
                  in_position++;
                }
            },
            _       => { fatal("Not implemented yet!"); },
        }
        pc++;
    }
    print_s(buffer);
}

fn main() {
    var path: u8[>..] = [];
    if arg_count() > 1 { arg(1, path); } else { arg(0, path); usage(path, "Provide source file"); }
    var src: u8[>..] = [];
    guard read_file(path, src) else { print("cannot read ", path); exit(1); }
    // print("source:\n", src);

    var ops: Op..[>..] = [];
    // references to elements in ops since variable arrays are not indexable
    var ops_at: (Op..&)[>..] = [];
    var stack: i64[>..<] = [];
    for c in src {
        var op = parse_op(c);
        // Manage special cases.
        match op {
            Nop => { continue; },
            Jz  off => { stack.push(ops.len); },
            Jnz off => {
                let jz = stack.pop();
                // We cannot index into ops?!!? Just iter over it.
                var j=0;
                for jop in ops {
                    if j == jz {
                        match jop {
                            Jz &off => { off = Op.Jz {ops.len}; },
                            _ => { fatal("Error retriving Jz"); }
                        }

                        break;
                    }
                    j++;
                }
                // ops[jz] = Op.Jz { ops.len };
                op = Op.Jnz { jz };
            },
            _ => {},
        }
        let ref = ops.push(op);
        ops_at.push(ref);
//        print("num ops: ", ops.len);
    }
    execute(ops_at);
}
