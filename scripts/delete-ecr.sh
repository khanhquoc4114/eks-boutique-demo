#!/bin/bash

# --- CẤU HÌNH (Phải khớp với lúc tạo) ---
AWS_REGION="us-east-1"
REPO_PREFIX="microservices-demo"

# Danh sách services (Copy y chang script tạo)
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

echo "🔴 CẢNH BÁO: Script này sẽ XOÁ VĨNH VIỄN các ECR Repositories sau:"
for SERVICE in "${SERVICES[@]}"; do echo " - ${REPO_PREFIX}/${SERVICE}"; done
echo "-------------------------------------------------------------"

# Bước hỏi xác nhận (Safety Check)
read -p "Ông có chắc chắn muốn xoá tất cả không? (y/n): " -n 1 -r
echo    # Xuống dòng
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ">>> Đã huỷ thao tác. Không có gì bị xoá."
    exit 1
fi

echo ">>> Bắt đầu tiến trình huỷ diệt..."

for SERVICE in "${SERVICES[@]}"
do
    REPO_NAME="${REPO_PREFIX}/${SERVICE}"
    
    echo "--- Đang xoá: $REPO_NAME ---"
    
    # Lệnh xoá kèm cờ --force để xoá luôn cả images bên trong
    aws ecr delete-repository \
        --repository-name "$REPO_NAME" \
        --region "$AWS_REGION" \
        --force \
        > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "🗑️  Đã xoá bay màu: $REPO_NAME"
    else
        echo "⚠️  Không tìm thấy repo $REPO_NAME hoặc đã bị xoá trước đó."
    fi
done

echo ">>> Dọn dẹp hoàn tất. Sạch như chưa từng có cuộc chia ly."