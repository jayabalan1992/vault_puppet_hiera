# Getting a vault instance
* `docker run --cap-add=IPC_LOCK -d -p 8200:8200 vault`
* Find the root token
  `docker logs <container-name>`
* set the address of the vault server:
  `export VAULT_ADDR='http://127.0.0.1:8200'`
* log in
  `vault auth <token>`

## test
```
~/p/hiera-vault vault write secret/foo value=bar
Success! Data written to: secret/foo
~/p/hiera-vault vault read secret/foo
Key                     Value
---                     -----
refresh_interval        768h0m0s
value                   bar
```
