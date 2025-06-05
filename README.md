# RabbitMQ Common Libraries

This library contains common modules shared by RabbitMQ server and client libraries.

## Building with rebar3

This project is now compatible with rebar3 and can be used as a dependency in other Erlang projects.

### Quick Start

```bash
rebar3 compile
```

The project includes pre-generated AMQP framing code, so no additional setup is required for regular usage.

### Using as a Dependency

Add to your `rebar.config`:

```erlang
{deps, [
    {rabbit_common, {git, "https://github.com/rabbitmq/rabbitmq-common.git", {branch, "main"}}}
]}.
```

### Development

If you need to regenerate the AMQP framing code during development:

```bash
rebar3 as dev compile
```

This will:
1. Fetch the `rabbitmq_codegen` dependency
2. Run the code generation scripts
3. Update the generated files

#### Manual Code Generation

You can also regenerate files manually:

```bash
./generate_sources.sh
```

This requires:
- Python interpreter
- The `rabbitmq_codegen` repository in `deps/rabbitmq_codegen/`

### Generated Files

The following files are generated from AMQP specifications and are included in the repository:

- `include/rabbit_framing.hrl` - AMQP framing header definitions
- `src/rabbit_framing_amqp_0_8.erl` - AMQP 0.8 protocol implementation
- `src/rabbit_framing_amqp_0_9_1.erl` - AMQP 0.9.1 protocol implementation

### Testing

```bash
rebar3 eunit
rebar3 ct
```

### Profiles

- `default` - Regular compilation with pre-generated files
- `dev` - Development mode with code generation
- `test` - Test dependencies (mochiweb)

### Minimum Requirements

- Erlang/OTP 18.0 or later
- Python (for code generation during development)
