# inspec2ckl
A small parser to take the JSON full output of an InSpec profile results and update the DISA Checklist file.

# Usage
## Command Line
```
#> ruby inspec2ckl.rb --help
Usage: inspec2ckl.rb [options]
    -c, --ckl ckl_file               the path to the DISA Checklist file (required)
    -j, --json json_file             the path to the InSpec JSON results file (required)
    -o, --output results.ckl         The file name you want for the output file (results.ckl)
    -m, --message "mesg"             A message to add to the control's "comments" section (optional)
    -V, --verbose,                   Show me the data!!! (true|*false)
    -v, --version                    inspec2ckl version
    -h, --help                       Displays Help
```

## Example
To use the parser, 
## Known Issues
- Issues welcome - please submit suggestions or issues on the board.
