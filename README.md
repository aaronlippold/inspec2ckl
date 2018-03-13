# inspec2ckl
A small parser to take the JSON full output of an InSpec profile results and update the DISA Checklist file.

# Usage
## Command Line
```
#> ./inspec2ckl --help
Usage: inspec2ckl.rb [options]
    -j --json : Path to Inspec results json file
    -c --cklist : Path to Stig Checklist file
    -t --title : Title of Stig Checklist file
    -d --date : Date of the Stig Checklist file
    -a --attrib : Path to attributes yaml file
    -o --output : Path to output checklist file
    -V --verbose : verbose run

```


## Attributes YAML 
```
title: 'NGINX'
date: '3-13-2018'
```

## Example
```
To run the parser:
  ./inspec2ckl exec -c checklist.ckl -j results.json -o output.ckl

To run the parser without xccdf:
  ./inspec2ckl exec -j results.json -o output.ckl

To run the parser with title and date:
  ./inspec2ckl exec -j results.json -o output.ckl -t nginx -d 03-13-2018

To run the parser with title and date from attrib yaml
  ./inspec2ckl exec -j results.json -o output.ckl -a attributes.yml

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