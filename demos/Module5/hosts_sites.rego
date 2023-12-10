
package test

import future.keywords.contains
import future.keywords.in
import future.keywords.if

site_and_hosts contains [name, host] {
    some site   in hosts.sites
    some server in site.servers

    name := site.name
    host := server.host
}


