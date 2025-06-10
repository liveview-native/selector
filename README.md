# CSS Selector Parser with NIF

A high-performance CSS selector parser for Elixir, implemented as a NIF using libcss.

## Installation

1. Install libcss development libraries:
   ```bash
   # On macOS
   brew install libcss
   
   # On Ubuntu/Debian
   # sudo apt-get install libcss-dev
   ```

2. Add `:selector` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [
       {:selector, "~> 0.1.0"}
     ]
   end
   ```

## Usage

```elixir
# Parse a CSS selector
{:ok, ast} = Selector.Parser.parse("div#main.content")
```

## Development

To compile the NIF:

```bash
make
```

To clean build artifacts:

```bash
make clean
```

## License

MIT

