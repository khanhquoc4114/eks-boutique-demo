#!/bin/bash

# --- CẤU HÌNH ---
AWS_REGION="us-east-1"
REPO_PREFIX="microservices-demo"
TAG="latest"

# Danh sách services
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

# 1. Lấy AWS Account ID
echo "🔍 Đang lấy thông tin tài khoản AWS..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Lỗi: Không lấy được AWS Account ID. Ông đã chạy 'aws configure' chưa?"
    exit 1
fi

echo "✅ Account ID: $ACCOUNT_ID"
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# 2. Đăng nhập ECR
echo "🔑 Đang đăng nhập vào ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$ECR_URL"

if [ $? -ne 0 ]; then
    echo "❌ Đăng nhập thất bại."
    exit 1
fi
echo "✅ Đăng nhập thành công!"

# 3. Vòng lặp Build & Push
echo "🚀 Bắt đầu quy trình Build & Push..."

for SERVICE in "${SERVICES[@]}"
do
    IMAGE_NAME="${REPO_PREFIX}/${SERVICE}"
    FULL_IMAGE_URL="${ECR_URL}/${IMAGE_NAME}:${TAG}"
    SRC_PATH="./src/${SERVICE}"
    
    echo "----------------------------------------------------"
    echo "🛠️  Service: $SERVICE"
    
    if [ ! -d "$SRC_PATH" ]; then
        echo "⚠️  Cảnh báo: Không tìm thấy thư mục $SRC_PATH. Bỏ qua."
        continue
    fi

    # --- LOGIC ĐÃ FIX CHO CARTSERVICE ---
    # Case 1: Chuẩn (Dockerfile nằm ngay thư mục service)
    if [ -f "${SRC_PATH}/Dockerfile" ]; then
        echo "🔨 Đang Build (Standard Mode)..."
        docker build -t "$IMAGE_NAME" "$SRC_PATH" > /dev/null

    # Case 2: Dị (Dockerfile nằm trong thư mục con src/ - Ví dụ cartservice)
    # FIX: Thay vì chỉ trỏ file (-f), ta đổi luôn Context vào trong folder src con
    elif [ -f "${SRC_PATH}/src/Dockerfile" ]; then
        echo "🔨 Đang Build (Deep Context Mode cho $SERVICE)..."
        # Đẩy Context vào sâu bên trong nơi chứa csproj
        docker build -t "$IMAGE_NAME" "${SRC_PATH}/src" > /dev/null
    
    else
        echo "❌ Lỗi: Tìm lòi mắt không thấy Dockerfile đâu cả trong $SRC_PATH"
        exit 1
    fi

    # Check kết quả build
    if [ $? -ne 0 ]; then
        echo "❌ Build thất bại cho $SERVICE. Kiểm tra lại code đi ông."
        exit 1
    fi

    # Tag & Push
    echo "🏷️  Đang Tag & Push..."
    docker tag "$IMAGE_NAME:$TAG" "$FULL_IMAGE_URL"
    docker push "$FULL_IMAGE_URL"

    if [ $? -eq 0 ]; then
        echo "✅ Xong con hàng: $SERVICE"
    else
        echo "❌ Push thất bại cho $SERVICE."
    fi
done

echo "----------------------------------------------------"
echo "🎉 HOÀN TẤT TOÀN BỘ! Cartservice giờ là chuyện nhỏ."