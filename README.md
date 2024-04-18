# Project 1: Bitcoin Mining using Distributed Systems
This project's objective is to mine coins using actor models that operate on multiple multi-core machines using Erlang Actor Model.
### Authors:
* Vaibhavi Deshpande
* Ishan Kunkolikar
### Pre-requisites:
* Erlang/OTP version - 25.1
### Steps to run:
1. START SERVER: Commands to start the server
``` 
erl -name bitcoinMiningServer@{ip_address} -setcookie dospproject1
c(bitcoinMiningServer).
bitcoinMiningServer:bitcoin_mining_server_start( n ).
```
Where ‘n’ is the number of zeroes

2. START CLIENT: Commands to start the client
``` 
erl -name bitcoinMiningClient@{ip_address} -setcookie dospproject1
c(bitcoinMiningClient).
bitcoinMiningClient:bitcoin_mining_client_start( ip_address ).
```
### Requirements
* **Input:** The input provided (as command line to yourproject1.fsx) will be, the required number of 0’s of the bitcoin.


* **Output:** The input string, and the correspondingSHA256 hash, for each of the bitcoins found. The SHA256 hash must have the required number of leading 0s (k = 3 means3 0’s in the hash notation).

### Implementation details:
1. The server is responsible for spawning actors to mine the bitcoins and also supervise the connected client nodes.
2. The server gets the input ‘n’ which is the number of required zeroes at the beginning of the hash generated. The number of actors spawned for mining the bitcoins is equal to the number of logical processors available on the node * 50 to optimize the overall performance.
3. A client connects to the server and after a connection is established, the server will send the number of zeroes and the work unit to the client. The client will independently start mining for coins according to the workload assigned and will send the mined coins back to the server.
4. After the work unit completes, the server will send the stop command to all clients and shut itself down.

### Size of the Work Unit:
The size of the work unit is 10000*(number of zeroes) which the server assigns to the connected client. Every node spawns the number of processes (actors) equal to 50 * (number of logical processors available on the node). The server is additionally responsible for supervising the workers and receiving the mined coin from all the actors.

### Results for Input -  4 zeroes
```
deshpande.v;jZaw8nOhid	0000479076d7cbdc3546196d14da1c740f19dfa43d58581a0894b56d990e0e37
deshpande.v;yLaF84ujFN	0000f1292d428c72b7b1af495304cf21c6b4d2fd63335e74fbc08b2894f7b4ca
deshpande.v;3fg8H1sEdt	000011c9e377896e465c4eccddababce4c79f20d7e800c9cf681a8969cb1a703
deshpande.v;7ot6N3paCx	000028c5aa02a609487b2c01e99bb27c1ce03296409e106baee7bcaf4f4bb4a2
deshpande.v;dfd542g4kT	000074ec613726865e2c60b28a2c1c2709ef7d4af13aa929a915b4c71c7b05f7
deshpande.v;Hu27Lkz9sl	000076da78fa14ce429af68ebda2125e3cc26104a38779f324cc48fc66c4527a
deshpande.v;JklV8tCC49	00008d4b93270e3aa0a027e87d85a7bc7f281c9b6b06db1aba7109c34a58e0a2
deshpande.v;j14VD+cv3h	000021c0ec2305d70c71a5ca8a7bcf166352652d605b163363f658531f58358d
deshpande.v;dUgMKzzns3	000090021c65bcff2fe89dc16319a2446cc95eaff52f4819ca5f0bcb64b9c8f0
deshpande.v;6+VuUs/qXm	000072fbf6e72436ebaa2cbefd87fda9cbed00ec43ccaf10fe55e8f8b3f4bd12
deshpande.v;90tTdEJ0Fi	00003a12c0eec3e329a8db2d1c94d124e3a6bfb57147b510c824b99164685984
deshpande.v;u73a0QSIvJ	0000fb03f192688125bc7cc79bd5c68ab0fd1409a962e797c35c38e33870424d
deshpande.v;0K8AomaAzI	0000173a6f0b62513ec5abf988ff9b7ca9daf332e5ba649c2d27a24931331b2b
deshpande.v;4iukMrKeTo	0000a123ef5979dbe462b566349381391740ab3aebe5901258492a127567eab7
deshpande.v;P4zz26mhaf	00002fefdfd35043bdb87666a6dd1ae88e944e3153ed8a13b0183dac4650ef83
deshpande.v;VEdQmlYg8n	00007a355cbf83f3e09a5888b932e5b68fa112dbc2356f29adec1c465e55b29d
deshpande.v;XhBQXVuJrR	0000037377d4d979c3830fcbbe18c5d0ec8746035103584444824f42b9bff3c4
deshpande.v;+Nr5zvStXR	0000f1376df6f8bffe7d5c4c445fcd1aaabacc0d13da6d4680e542bdb9d575f6
deshpande.v;QQThphLGNO	00006e91d552145d4caf95ec8da438a6d18f1d1663172096747450a786366b7a
deshpande.v;ivNGomY0Cb	00003002f52c9eb11b2e01b7b1d305f47144551e697ebce9b25150408a7b5dd6
```

### Running Time
* Ratio CPU Time / Real-Time: **7.11**

### Coin with most zeroes (8):
```
deshpande.v;8emgRak7KE 0000000052bb2f9bd7574c3a9f063b1facce939cf2b3c8e66f90779b0b3216c9
```
### The largest number of working machines connected:
This code was run on a maximum of 4 machines, with one as the server and 3 client machines. 






