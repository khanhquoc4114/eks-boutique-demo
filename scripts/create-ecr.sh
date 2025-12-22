#!/bin/bash

# --- CẤU HÌNH ---
AWS_REGION="us-east-1" 
REPO_PREFIX="microservices-demo"

# Danh sách đầy đủ các service trong Google Microservices Demo
SERVICES=(
    "emailservice"
    "productcatalogservice"
    "recommendationservice"
    "shippingservice"
    "checkoutservice"
    "paymentservice"
    "currencyservice"
    "cartservice"
    "frontend"
    "adservice"
    "loadgenerator"
)

echo ">>> Bắt đầu tạo ECR Repositories tại region: $AWS_REGION..."

for SERVICE in "${SERVICES[@]}"
do
    REPO_NAME="${REPO_PREFIX}/${SERVICE}"
    
    echo "--- Đang tạo repo: $REPO_NAME ---"
    
    aws ecr create-repository \
        --repository-name "$REPO_NAME" \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true \
        > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✅ Đã tạo xong: $REPO_NAME"
    else
        echo "⚠️  Repo $REPO_NAME có thể đã tồn tại hoặc có lỗi xảy ra."
    fi
done

echo ">>> Hoàn tất! Ông kiểm tra lại trên Console nhé."