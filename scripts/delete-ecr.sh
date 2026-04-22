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

echo "Canh bao: Script nay se xoa vinh vien cac ECR repositories sau:"
for SERVICE in "${SERVICES[@]}"; do echo " - ${REPO_PREFIX}/${SERVICE}"; done
echo "-------------------------------------------------------------"

read -p "Ban co chac chan muon xoa tat ca? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Da huy thao tac."
    exit 1
fi

echo "Bat dau xoa repositories..."

for SERVICE in "${SERVICES[@]}"
do
    REPO_NAME="${REPO_PREFIX}/${SERVICE}"
    
    echo "Dang xoa: $REPO_NAME"
    
    aws ecr delete-repository \
        --repository-name "$REPO_NAME" \
        --region "$AWS_REGION" \
        --force \
        > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Da xoa: $REPO_NAME"
    else
        echo "Khong tim thay repo $REPO_NAME hoac da duoc xoa truoc do"
    fi
done

echo "Hoan tat xoa repositories."