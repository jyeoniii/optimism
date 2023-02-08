helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis --set architecture=standalone bitnami/redis
helm install postgres \
  --set global.postgresql.auth.postgresPassword=password \
  --set global.postgresql.auth.database=blockscout \
  --set-string 'primary.extraEnvVars[0].name=POSTGRESQL_MAX_CONNECTIONS,primary.extraEnvVars[0].value=500' \
  bitnami/postgresql

kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=postgresql \
  --timeout=90s

kubectl wait --namespace default \
  --for=condition=ready pod \
  --selector= app.kubernetes.io/name=redis \
  --timeout=90s

kubectl create cm blockscout-cm --from-env-file=blockscout.env
kubectl create -f blockscout.yaml
