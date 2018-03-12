# inspec2ckl
A small parser to take the JSON full output of an InSpec profile results and update the DISA Checklist file.

# Usage
## Command Line
```
#> ./inspec2ckl --help
Usage: inspec2ckl.rb [options]
    -c, --cklist ckl_file            the path to the DISA Checklist file (required)
    -j, --json json_file             the path to the InSpec JSON results file (required)
    -o, --output results.ckl         The file name you want for the output file (results.ckl)
    -V, --verbose,                   Show me the data!!!
    -v, --version                    inspec2ckl version
    -h, --help                       Displays Help
```

## Example
```
To run the parser:
  ./inspec2ckl exec -c checklist.ckl -j results.json -o output.ckl

To run the parser verbose:
  ./inspec2ckl exec -c checklist.ckl -j results.json -o output.ckl -V

Help:
  ./inspec2ckl help

Version:
  ./inspec2ckl -v
```
## Known Issues
- Validation for the Json and XML files not yet implemented
- More Issues welcome - please submit suggestions or issues on the board.
- Error occurred while installing libxml-ruby (2.9.0) on MacOS.
  Solution: https://gist.github.com/unixcharles/1226596