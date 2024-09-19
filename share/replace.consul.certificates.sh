#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

rm *.pem

shopt -s expand_aliases
alias consul="/usr/local/bin/consul-1.12.9"

# Create a new  certificate authority:

consul tls ca create;

# ==> consul-agent-ca.pem  # non-sensitive
# ==> consul-agent-ca-key.pem  # sensitive

# TODO: Check -additional-name and redo if needed so that uis can be served over https.
# TODO: cli certificates

svc="consul"
mesh="${svc}.service.consul"
for N in ${!consuls[@]};
do
	ip="${consuls[$N]}"
	node="${svc}-${N}"
	dns="${node}.${dn}"
	consul tls cert create -server -dc=${dc} -days=${days} \
		-additional-ipaddress=${ip} \
		-additional-dnsname=${dns} \
        	-additional-dnsname=${mesh} \
		-ca=consul-agent-ca.pem \
        	-domain=${svc} \
        	-key=consul-agent-ca-key.pem \
        	-node=${node};
        deploy_consul_server $ip "${dc}-server-${svc}-${N}"
done;

svc="vault"
mesh="${svc}.service.consul"
for N in "${!vaults[@]}";
do
	ip="${vaults[$N]}"
	node="${svc}-${N}"
	dns="${node}.${dn}"
	consul tls cert create -client -dc=${dc} -days=${days} \
        	-additional-ipaddress=${ip} \
        	-additional-dnsname=${dns} \
        	-additional-dnsname=${mesh} \
		-ca=consul-agent-ca.pem \
        	-domain=${svc} \
        	-key=consul-agent-ca-key.pem;
        deploy_consul_client $ip "${dc}-client-${svc}-${N}"
done;

svc="nomad"
mesh="${svc}.service.consul"
for N in "${!nomads[@]}";
do
	ip="${nomads[$N]}"
	node="${svc}-${N}"
	dns="${node}.${dn}"
	consul tls cert create -client -dc=${dc} -days=${days} \
        	-additional-ipaddress=${ip} \
        	-additional-dnsname=${dns} \
        	-additional-dnsname=${mesh} \
		-ca=consul-agent-ca.pem \
        	-domain=${svc} \
        	-key=consul-agent-ca-key.pem;
        deploy_consul_client $ip "${dc}-client-${svc}-${N}"
done;

svc="haproxy"
mesh="${svc}.service.consul"
for N in "${!haproxies[@]}";
do
	ip="${haproxies[$N]}"
	node="${svc}-${N}"
	dns="${node}.${dn}"
	consul tls cert create -client -dc=${dc} -days=${days} \
        	-additional-ipaddress=${ip} \
        	-additional-dnsname=${dns} \
        	-additional-dnsname=${mesh} \
		-ca=consul-agent-ca.pem \
        	-domain=${svc} \
        	-key=consul-agent-ca-key.pem;
        deploy_consul_client $ip "${dc}-client-${svc}-${N}"
done;

svc="jump"
mesh="${svc}.service.consul"
for N in "${!jumps[@]}";
do
	ip="${jumps[$N]}"
	node="${svc}-${N}"
	dns="${node}.${dn}"
	consul tls cert create -client -dc=${dc} -days=${days} \
        	-additional-ipaddress=${ip} \
        	-additional-dnsname=${dns} \
        	-additional-dnsname=${mesh} \
		-ca=consul-agent-ca.pem \
        	-domain=${svc} \
        	-key=consul-agent-ca-key.pem;
        deploy_consul_client $ip "${dc}-client-${svc}-${N}"
done;

svc="minion"
mesh="${svc}.service.consul"
for N in "${!minions[@]}";
do
	ip="${minons[$N]}"
	node="${svc}-${N}"
	dns="${node}.${dn}"
	consul tls cert create -client -dc=${dc} -days=${days} \
        	-additional-ipaddress=${ip} \
        	-additional-dnsname=${dns} \
        	-additional-dnsname=${mesh} \
		-ca=consul-agent-ca.pem \
        	-domain=${svc} \
        	-key=consul-agent-ca-key.pem;
        deploy_consul_client $ip "${dc}-client-${svc}-${N}"
done;
