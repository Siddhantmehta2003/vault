
import dns.resolver
try:
    answers = dns.resolver.resolve('_mongodb._tcp.cluster0.tevhrmw.mongodb.net', 'SRV')
    for rdata in answers:
        print(f'Host: {rdata.target} Port: {rdata.port}')
except Exception as e:
    print(f'DNS Error: {e}')
