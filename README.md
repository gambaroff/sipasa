Let's say you wanted to build your own DHCP server one thing you gonna need to do is proide a way to
Sipasa does this part for you
Sipasa is Stephania's IP Address Super Allocator!

Curl's an easy way to operate with this bad boy.

Run in dev
rerun 'rackup'

List pools:
curl -XGET http://127.0.0.1:9292/pools

Show a pool:
curl -XGET http://127.0.0.1:9292/pools/first

Add a pool:
curl -XPUT http://127.0.0.1:9292/pools/second -d @poolcreate.json
or stdin:
curl -XPUT http://127.0.0.1:9292/pools/second -d @-
{"range": "10.10.0.0/24"}
<Ctl-D>

Show interfaces:
curl -XGET http://127.0.0.1:9292/interfaces

Show an interface:
curl -XGET http://127.0.0.1:9292/interfaces/cheddarcheese.example.com

Create an interface:
curl -XPUT http://127.0.0.1:9292/pools/second/mahchegocheese.example.com -d @-
{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}
^D

Show IPs:
curl -XGET http://127.0.0.1:9292/ips

Show an IP:
curl -XGET http://127.0.0.1:9292/ips/192.168.2.4


Show hosts:
curl -XGET http://127.0.0.1:9292/hosts

Show an interface:
curl -XGET http://127.0.0.1:9292/hosts/manchegocheese


