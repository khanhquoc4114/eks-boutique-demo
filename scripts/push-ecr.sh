#!/bin/bash

AWS_REGION="us-east-1"
REPO_PREFIX="microservices-demo"
TAG="latest"

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

echo "Dang lay AWS account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$ACCOUNT_ID" ]; then
    echo "Loi: Khong lay duoc AWS account ID. Vui long kiem tra cau hinh AWS CLI."
    exit 1
fi

echo "Account ID: $ACCOUNT_ID"
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Dang dang nhap ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$ECR_URL"

if [ $? -ne 0 ]; then
    echo "Dang nhap ECR that bai."
    exit 1
fi
echo "Dang nhap ECR thanh cong."

echo "Bat dau quy trinh build va push images..."

for SERVICE in "${SERVICES[@]}"
do
    IMAGE_NAME="${REPO_PREFIX}/${SERVICE}"
    FULL_IMAGE_URL="${ECR_URL}/${IMAGE_NAME}:${TAG}"
    SRC_PATH="./src/${SERVICE}"
    
    echo "----------------------------------------------------"
    echo "Service: $SERVICE"
    
    if [ ! -d "$SRC_PATH" ]; then
        echo "Khong tim thay thu muc $SRC_PATH. Bo qua service nay."
        continue
    fi

    if [ -f "${SRC_PATH}/Dockerfile" ]; then
        echo "Dang build (standard mode)..."
        docker build -t "$IMAGE_NAME" "$SRC_PATH" > /dev/null

    elif [ -f "${SRC_PATH}/src/Dockerfile" ]; then
        echo "Dang build (deep context mode)..."
        docker build -t "$IMAGE_NAME" "${SRC_PATH}/src" > /dev/null
    
    else
        echo "Loi: Khong tim thay Dockerfile trong $SRC_PATH"
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "Build that bai cho $SERVICE"
        exit 1
    fi

    echo "Dang tag va push..."
    docker tag "$IMAGE_NAME:$TAG" "$FULL_IMAGE_URL"
    docker push "$FULL_IMAGE_URL"

    if [ $? -eq 0 ]; then
        echo "Da push thanh cong: $SERVICE"
    else
        echo "Push that bai: $SERVICE"
    fi
done

echo "----------------------------------------------------"
echo "Hoan tat build va push images."