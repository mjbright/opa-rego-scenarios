# sites

### sites.json

Contains a simple JSON structure to define several Sites, each with several Servers.

### sites_1_oldstyle.rego

Uses old style Rego notation, rather than contains/in/if keywords

List the unique server names (not FQDN so overlapping)

Demonstrates use of ``_`` anonymous variable (multiple times)

`` data.sites[_].servers[_].host```

### sites_1.rego

Uses new style Rego notation, using contains/in/if keywords

List the unique server names (not FQDN so overlapping)

Makes use of ``contains ... if`` syntax`

Makes use of ``some ... in`` syntax`

### sites_2.rego

Makes use of string concat(delim, [array]) function to build up FQDN of each server hostname

