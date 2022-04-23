# pp
Dumb wrapper for matplotlib that is significantly easier to use then gnuplot but has no powerful features

# Usage

```bash
$ data='[{"a":1,"b":2,"c":3,"timestamp":100},{"a":3,"b":2.5,"c":4,"timestamp":110},{"a":5,"b":3.5,"c":0,"timestamp":120}]'
$ echo "$data" | pp *:timestamp
$ echo "$data" | pp :timestamp
$ echo "$data" | pp a:timestamp
$ echo "$data" | pp a,b:timestamp
```

```bash
$ data='[{"status":"a","cnt":10,"date":"2022-04-23"},{"status":"b","cnt":20,"date":"2022-04-23"},{"status":"b","cnt":5,"date":"2022-04-22"},{"status":"a","cnt":15,"date":"2022-04-22"},{"status":"a","cnt":20,"date":"2022-04-21"},{"status":"b","cnt":7,"date":"2022-04-21"},{"status":"unknown","cnt":30,"date":"2022-04-21"},{"status":"a","cnt":5,"date":"2022-04-20"},{"status":"unknown","cnt":23,"date":"2022-04-20"}]'
$ echo "$data" | pp status=cnt:date
```
