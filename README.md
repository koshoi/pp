# pp
Dumb wrapper for matplotlib that is significantly easier to use then gnuplot but has no powerful features

# Usage

```bash
$ data='[{"a":1,"b":2,"c":3,"timestamp":100},{"a":3,"b":2.5,"c":4,"timestamp":110},{"a":5,"b":3.5,"c":0,"timestamp":120}]'
$ echo "$data" | pp -p "*:timestamp"
$ echo "$data" | pp -p "a:timestamp"
$ echo "$data" | pp -p "a,b:timestamp"
```
