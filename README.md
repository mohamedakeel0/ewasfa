# Ewasfa

This project is for the Migration of the obsolete Easy1Rx app into a new codebase, written in Flutter.

## Diagrams

- [Ewasfa User Scenarios](https://drive.google.com/file/d/1-GFXHosuzQ9l6MRN68pOY-LZjS03gIdJ/view?usp=sharing)

- [Ewasfa Class Diagram](https://drive.google.com/file/d/1Rfozq356TLTm3wGjZhYD0CJhtPqoGB_e/view?usp=sharing)

## File Structure

```
- lib/
  - helpers/
  - models/
  - services/
  - providers/
  - screens/
  - widgets/
  - main.dart
```

## Documentation

Documentation for this project was created and generated according to standards set in the [Effective Dart: Documentation | Dart](https://dart.dev/effective-dart/documentation)

Developer Documentation for this project can be found in /doc/api

You can view the docs directly from the file system, but if you want to use the search function, you must load them with an HTTP server.

An easy way to run an HTTP server locally is to use the dhttpd package. For example:

```bash
$ dart pub global activate dhttpd
$ dhttpd --path doc/api
```

Then, you can simply navigate to the following link through your browser to view the docs with the search function

```http
http://localhost:8080
```

To update documentation for this project, simply follow the guide provided for Effective Dart Documentation, then run the following command in a terminal at the project root directory:

```bash
dart doc
```

and wait for the process to complete. On successful completion, the existing docs should be overwritten by the new docs.