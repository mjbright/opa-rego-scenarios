
package play

import future.keywords


all_hosts[hosts] {
    hosts := data.sites[_].servers[_].host
}


