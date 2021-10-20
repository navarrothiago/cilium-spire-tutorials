## Requirements: 
- Minikube
- jq
- helm

## Steps

Create clusters:

```
./0-start-clusters.sh
```

Execute the loop. It will create and delete the pods:

```
./loop.sh
```

Check the `logs-date-loop.txt` file.

Clean-up:

```
./3-delete-clusters.sh
```



