Pelias Dashboard
----------------
* build using the Dashing framework: check out http://shopify.github.com/dashing for more information.

Basics
------
* if you're running Pelias and want to get some information at a glance...

```
bundle install
ES_ENDPOINT=http://your_es_hostname_or_ip:9200/pelias dashing start
```

* navigate to http://localhost:3030 in your browser

Docker
------
There is an included Dockerfile that can be used to run the dashboard
