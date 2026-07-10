# Open Source Compliance

MoonRedactKit is distributed under the Apache License, Version 2.0.

## Project license

- The root `LICENSE` file contains the complete Apache License 2.0 text,
  including terms, conditions, disclaimer, and appendix.
- The root `NOTICE` file identifies MoonRedactKit and points reviewers to the
  complete project license.
- `moon.mod` declares `license = "Apache-2.0"` so package metadata and source
  files describe the same license.

## Third-party code and assets

The repository does not vendor third-party source code, generated libraries, or
external media assets. Documentation, tests, examples, and application
materials are project-owned files created for this repository.

## Review checklist

Use the following commands before submission:

```bash
moon fmt
moon info
moon check --target all
moon test --target all
moon package
```

The project is intended to remain backend neutral. Core source files avoid
platform-specific IO and browser APIs so the package can be checked for native,
JavaScript, WebAssembly, and Wasm GC targets.
