
package play

import future.keywords

all_hosts contains hosts if {
    some site in data.sites
    some host in site.servers[_]

    hosts := host
}

