# 1. Tải aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
# 2. Cài đặt profile
aws configure --profile quocndk
# 3. Kiểm tra 
aws sts get-caller-identity
# 4. Chạy tạo ecr 
# 5. Chạy tag docker
docker tag microservices-demo/frontend:latest 671838581040.dkr.ecr.us-east-1.amazonaws.com/microservices-demo/frontend:latest
# 6. Tải eksctl 
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
# 7. Khởi tạo eks
eksctl create cluster --name demo-shop --region us-east-1 --nodegroup-name spot-workers --node-type t3.medium --nodes 2 --nodes-min 2 --nodes-max 3 --managed --spot
# 8. Chạy manifest
kubectl apply -f ./k8s-manifests/
# 9. Kiểm tra
kubectl get svc -A