# Linux Process Forensics

Linux process environment allows to extract interesting information about used commands and directories, users, system variables, SSH connection, etc.

The SSH information extracted from a process is really interesting since it allows to know the ip from where the access occurred, datatimes, etc.

It is necessary not to kill a suspicious process since important information can be destroyed.

```/proc/<pid>/environ```

With the pid of the process we can access your data "environ"

**What is interesting for the analyst?**
  - Antiforensic
  - Ip ssh source
  - Environment variables

[Script for Process Forensics Analysis](https://github.com/fmuinos/process_forensics/blob/master/process_forensics.sh)

**Process**

1. In the victim we check the existing processes:

```
ps -auxwv
```

2. We look for strange processes or not of the system

   - We check the system ports:
```
Netstat -nalp | more
```

In the active internet connections we can find the different ports established for the strange processes. In the process that interests us, we write down the PID

3. We extract the process environment
```
Strings /proc/<pid>/environ
```
  - histsize if it is 0 can indicate an antiforensic action
  - sshconnection, with ip source and port and destination source and port.
  - sshclient, with ip and port source

4. Find all processes automatically those that have ssh client.
```
find /proc -name environ -maxdepth 2 -type f 2>/dev/null | xargs grep -o "SSH_CLIENT" 2>/dev/null
```

5. obtain / proc listing for suspicious process ID
```
ls -al /proc/<pid>
```
  - know the current working directory
  - binary deleted or not
  - the datestamp creation date can serve to know when the process was created.

6. Recover linux malware binary
While the process is running you can recover the deleted binary
```
cp /proc/<pid>/exe ./recovered
```

7. calculate hash of the binary obtained or send to virustotal
```
Sha1sum /bin/nc
Sha1sum ./recovered
```

8. explore malware command line
The command line is stored under ```/proc/<PID>```/ cmdline and the command name is shown under ```/proc/<PID>/comm```

9. know the open file descriptors
To discover hidden files and directories that the malware may be using.
```
ls -al /proc/<PID>/fd
```

10. linux process maps
It shows libraries that malware is using and other files that it may be using
```
cat /proc/<PID>/maps
```

11. Process stack
```
cat /proc/<PID>/stack
```
You can reveal more details ...

12. malware status
For process details. As parent PIDs ... memory usage ...
```
cat /proc/<PID>/status
```

**Example Extraction: extract.txt**

pid|command|path|oldpath|args|sha1|ipsrc|portsrc|ipdst|portdst

2515|bash|||-bash|59fea2c26edbbab48daaf73e7cd16ebc47475e83|127.0.0.1|51144|127.0.0.1|22

4423|x7|/tmp|/home/emanon/Documentos/process_forensics|./x7-vv-k-w1 l31337|17e5fc46c25360bed448927dd76548a122517d46|127.0.0.1|51144|127.0.0.1|22
