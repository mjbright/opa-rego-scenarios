 
cd $( dirname $0 )

opa eval --coverage -d ./data.hosts.rego -d ./hosts_sites.rego 'data.test.site_and_hosts'
