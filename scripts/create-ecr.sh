#!/bin/bash

AWS_REGION="us-east-1" 
REPO_PREFIX="microservices-demo"

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

echo "Bat dau tao ECR repositories tai region: $AWS_REGION"

for SERVICE in "${SERVICES[@]}"
do
    REPO_NAME="${REPO_PREFIX}/${SERVICE}"
    
    echo "Dang tao repo: $REPO_NAME"
    
    aws ecr create-repository \
        --repository-name "$REPO_NAME" \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true \
        > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Da tao: $REPO_NAME"
    else
        echo "Bo qua: $REPO_NAME (co the da ton tai hoac co loi)"
    fi
done

echo "Hoan tat tao repositories."