### Flow render markdown over ssh

need to try: Install https://github.com/charmbracelet/glow on remote

On remote:
1. python3.10 -m pip install --user grip
2. long host name (FQDN: Fully Qualified Domain Name): hostname -f
3. python3.10 -m grip <md file name> 127.0.0.1:8080

On local:
1. Tunnel: ssh -L 8080:127.0.0.1:8080 <FQDN>
2. View in browser: http://localhost:8080/
