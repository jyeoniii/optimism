# Create Kind Cluster (NOTE: You can install kind by running `brew install kind`)
kind create cluster --config=config-with-mounts.yaml

# Load Docker image
kind load docker-image ops-bedrock_l1
kind load docker-image ops-bedrock_l2
kind load docker-image ops-bedrock_op-node
kind load docker-image ops-bedrock_op-proposer
kind load docker-image ops-bedrock_op-batcher
kind load docker-image ops-bedrock_stateviz
kind load docker-image blockscout/blockscout

kubectl create -f l1.yaml
kubectl create -f l2.yaml

kubectl wait --for=condition=ready pod --selector=app=l1 --timeout=90s
kubectl wait --for=condition=ready pod --selector=app=l2 --timeout=90s

# Configure Blockscout
sh kube-configure-blockscout.sh

kubectl create -f op-log-pv.yaml
kubectl create -f op-node.yaml
kubectl wait --for=condition=ready pod --selector=app=op-node --timeout=90s

kubectl create -f op-proposer.yaml
kubectl create -f op-batcher.yaml
kubectl create -f stateviz.yaml
kubectl create -f ingress.yaml

# Deploy Ingress NGINX
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait until is ready to process requests running
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "Successfully configured optimism network!"
echo " > L1 RPC: http://l1-rpc.iskra.world"
echo " > L2 RPC: http://l2-rpc.iskra.world"
echo " > OP Node RPC: http://op-node-rpc.iskra.world"
echo " > L1 Explorer: http://l1-explorer.iskra.world"
echo " > L2 Explorer: http://l2-explorer.iskra.world"
