#!/bin/bash

set -euxo pipefail

docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"

docker build -t "$DOCKER_USERNAME"/rabbitmq-fd:0.1.0 .
docker push "$DOCKER_USERNAME"/rabbitmq-fd:0.1.0

gcloud beta container --project "$GCP_PROJECT" clusters create "test" \
    --zone "$GCP_ZONE" \
    --num-nodes "1" \
    --image-type "UBUNTU_CONTAINERD" \
    --cluster-version "1.25.4-gke.1600" \
    --machine-type "e2-highcpu-8" \
    --release-channel "rapid" \
    --disk-type "pd-balanced" \
    --disk-size "20" \
    --no-enable-basic-auth \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --max-pods-per-node "110" \
    --logging=SYSTEM,WORKLOAD \
    --monitoring=SYSTEM \
    --enable-ip-alias \
    --network "projects/$GCP_PROJECT/global/networks/default" \
    --subnetwork "projects/$GCP_PROJECT/regions/europe-west3/subnetworks/default" \
    --no-enable-intra-node-visibility \
    --default-max-pods-per-node "110" \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
    --enable-autoupgrade \
    --enable-autorepair \
    --max-surge-upgrade 1 \
    --max-unavailable-upgrade 0 \
    --enable-shielded-nodes --node-locations "$GCP_ZONE"

kubectl get nodes | grep Ready | awk '{print $1}' | xargs -I {} gcloud compute ssh {} --zone "$GCP_ZONE" -- "sudo sysctl -w fs.nr_open=10000000"

kubectl apply -f https://github.com/rabbitmq/cluster-operator/releases/download/v2.1.0/cluster-operator.yml
sleep 20
sed "s/{{docker_username}}/$DOCKER_USERNAME/" my-rabbit.yml | kubectl apply -f -
sleep 20
kubectl wait --for=condition=Ready=true pods -lapp.kubernetes.io/name=my-rabbit --timeout=5m

# This should print a number that's almost 10 million.
kubectl exec my-rabbit-server-0 -c rabbitmq -- rabbitmqctl status | grep -A 4 "File Descriptors"
