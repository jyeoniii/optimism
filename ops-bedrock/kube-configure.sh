# Create Kind Cluster
kind create cluster --config=config-with-mounts.yaml

# Load Docker image
kind load docker-image ops-bedrock_l1
kind load docker-image ops-bedrock_l2
kind load docker-image ops-bedrock_op-node
kind load docker-image ops-bedrock_op-proposer
kind load docker-image ops-bedrock_op-batcher
kind load docker-image ops-bedrock_stateviz

# Deploy Ingress NGINX
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait until is ready to process requests running
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl create -f l1.yaml
kubectl create -f l2.yaml
kubectl create -f op-log-pv.yaml
kubectl create -f op-node.yaml
kubectl create -f op-proposer.yaml
kubectl create -f op-batcher.yaml
kubectl create -f stateviz.yaml
kubectl create -f ingress.yaml

echo "Successfully configured optimism network!"
echo " > L1 RPC: http://localhost/l1"
echo " > L2 RPC: http://localhost/l2"
echo " > OP Node RPC: http://localhost/op-node"
