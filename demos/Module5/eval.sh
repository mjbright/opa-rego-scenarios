 
cd $( dirname $0 )

opa eval -d ./data.hosts.rego -d ./hosts_sites.rego 'data.test.site_and_hosts'
