# CustomEmoji

Download custom emoji from Slack

## Install

```sh
git clone https://github.com/fromkk/SlackCustomEmoji.git
cd SlackCustomEmoji
make install
```

## Usage

```sh
CustomEmoji --help
USAGE: custom-emoji <directory> [--user-display-name <user-display-name>] [--from <from>] [--to <to>] [--download <download>]

ARGUMENTS:
  <directory>             Path to custom emoji jsons. 

OPTIONS:
  -u, --user-display-name <user-display-name>
                          UserDisplayName for filter 
  -f, --from <from>       filtering from YYYYMMDD 
  -t, --to <to>           filtering to YYYYMMDD 
  -d, --download <download>
                          path to Download directory 
  -h, --help              Show help information.
```


