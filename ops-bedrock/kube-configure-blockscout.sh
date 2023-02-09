helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis --set architecture=standalone bitnami/redis
helm install postgres \
  --set global.postgresql.auth.postgresPassword=password \
  --set-string 'primary.extraEnvVars[0].name=POSTGRESQL_MAX_CONNECTIONS,primary.extraEnvVars[0].value=500' \
  --set primary.initdb.scripts."init\.sql"='create database blockscout_l1;create database blockscout_l2;' \
  bitnami/postgresql

kubectl wait --for=condition=ready pod --selector=app.kubernetes.io/name=postgresql --timeout=90s
kubectl wait --for=condition=ready pod --selector=app.kubernetes.io/name=redis --timeout=90s

kubectl create cm blockscout-cm --from-env-file=blockscout.env
kubectl create cm smart-contract-verifier-cm --from-env-file=smart-contract-verifier.env

# TODO: Change to use helm chart
kubectl create -f blockscout-l1.yaml
kubectl create -f blockscout-l2.yaml

kubectl wait --for=condition=ready pod --selector=app=blockscout_l1 --timeout=90s
kubectl wait --for=condition=ready pod --selector=app=blockscout_l2 --timeout=90s
