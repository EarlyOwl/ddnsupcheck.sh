# ddnsupcheck.sh

[![ShellCheck](https://github.com/EarlyOwl/ddnsupcheck.sh/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/EarlyOwl/ddnsupcheck.sh/actions/workflows/shellcheck.yml)

Automatically checks if your public IP has changed, and if so it verifies if your DDNS record has been updated accordingly.

## Contents
- [What is this?](#what-is-this)
- [How does it work?](#how-does-it-work)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Misc](#misc)

## What is this?
This script is intended to run periodically (with a cronjob) to check if the public IP address of the machine has changed, and if so it checks if your custom DDNS record was updated accordingly. Without further customization it just logs these events under a file named ```log.txt``` and keeps an history of the IP addresses under ```ip_history.txt```.

## How does it work?
The first time the script runs it will create a file named ```lastrun_ip.txt``` where it will store your current public IP address (retrieved with ```curl https://ipinfo.io/ip```). This file will be used in the next runs to check if there was an IP change.

Then at each next run the behavior will vary:

1. **The public IP address didn't change since last time:** an event of severity ```INFO``` is logged.

2. **The public IP address has changed, but the DDNS record was updated accordingly:** the new IP address is saved with a timestamp in the file ```ip_history.txt``` and an event of severity ```WARN``` is logged. You could add a custom action inside the ```if``` block, e.g. to send you a notification or make an API call.

3. **The public IP address has changed, and the DDNS record doesn't match the new IP:** an event of severity ```CRIT``` is logged. You could add a custom action inside the ```if``` block, e.g. to update the record or send you a notification.

4. **The ```curl``` command fails (e.g. lack of connectivity):** an event of severity ```CRIT``` is logged.

5. **The ```dig``` command fails (e.g. wrong dns record):** an event of severity ```CRIT``` is logged.

## Prerequisites
You won't need much. Your system must be able to run ```dig``` and ```curl```, which shouldn't be a problem on any distro. Your firewall (if any) should allow traffic to ```https://ipinfo.io```, used to retrieve your public IP address.


## Installation

1. Download ddnsupcheck.sh from the main branch to your local machine:

```shell
wget https://raw.githubusercontent.com/EarlyOwl/ddnsupcheck.sh/main/ddnsupcheck.sh
```
2. Make it executable:

```shell
chmod +x ddnsupcheck.sh
```
3. Open the script with your editor of choice:

```shell
nano ddnsupcheck.sh
```
4. Edit the following variables to fit your needs:

```shell
#Your DDNS record to check
ddnsrecord="yourddnsrecord.example.com"

#Path for writing logs and other files. Default is current directory
workpath="."

#Timestamp used for logging. The default format is dd/mm/yyyy#h:m:s
timestamp=$(date +%d/%m/%y@%H:%M:%S)
```

5. You can run the script manually with:

```shell
./ddnsupcheck.sh
```

But it would be better to set up a cronjob, for example to run each 5 minutes:

```
*/5 * * * * ./path/to/script/ddnsupcheck.sh
```

6. (Optional) - Add some custom actions inside the ```if``` blocks of the script, e.g. sending a notification, updating the record, etc...

## Misc

##### Can I contribute? Can I reuse all/part of this script for other purposes?
Yes and yes.

##### This sucks / You could have done X instead of X!
I'm eager to learn, open an issue or a  pull request to suggest an improvement / fix.
