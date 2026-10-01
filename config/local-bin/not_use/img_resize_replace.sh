#!/bin/bash

# 사용법 안내 함수
usage() {
    echo "Usage: $0 <file_or_folder1> [file_or_folder2] ..."
    echo "This script resizes images in the specified folder(s) or file(s) to a maximum width of 1920 pixels."
    echo "The original file is replaced by the resized one, and a suffix is added to the filename before the extension."
    exit 1
}

# 인수가 없으면 사용법 출력
if [ "$#" -eq 0 ]; then
    usage
fi

# ImageMagick의 'convert' 명령어 사용 가능 여부 확인
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick (convert command) is not installed."
    echo "Please install it (e.g., 'sudo apt install imagemagick' on Debian/Ubuntu)."
    exit 1
fi

# 새 파일 이름에 추가할 접미사 설정
NEW_SUFFIX="-w1920x" # <-- 원하는 단어로 변경 가능

# 리사이징 함수 정의
process_file() {
    local file="$1"
    
    # 지원하는 이미지 파일 확장자인지 확인
    if [[ "$file" =~ \.(jpg|jpeg|png)$ ]]; then
        # 이미 접미사가 붙은 파일은 건너뜀 (무한 루프 방지)
        if [[ "$file" == *"${NEW_SUFFIX}."* ]]; then
            #echo "Skipping already processed file: $file"
            return
        fi

        filename=$(basename -- "$file")
        extension="${filename##*.}"
        base="${filename%.*}"
        
        # 새 파일 이름 설정: [원본이름][접미사].[확장자]
        new_filename="${base}${NEW_SUFFIX}.${extension}"
        new_file_path="${file%/*}/$new_filename"
        
        echo "Processing: $file"
        
        # 1. convert 명령어를 사용하여 최대 너비 1920px로 리사이즈하여 새 파일로 저장
        # -resize '1920x>'는 너비가 1920px보다 크거나 같은 경우에만 리사이즈합니다.
        convert "$file" -resize '1920x>' "$new_file_path"
        
        # 2. convert 성공 여부 확인 및 원본 파일 삭제 후 이름 변경
        if [ $? -eq 0 ]; then
            echo "Successfully resized and saved as: $new_file_path"
            
            # 원본 파일 삭제
            rm "$file"
            
            # 리사이즈된 파일을 원본 이름으로 다시 변경
            #mv "$new_file_path" "$file"
            #echo "--> File REPLACED (max width 1920px): $file"
            
        else
            echo "Error processing: $file. Original file kept."
        fi
    fi
}

# 입력된 각 인수를 처리
for input in "$@"; do
    if [ -d "$input" ]; then
        # 폴더인 경우: 지정된 확장자의 파일들을 찾아 처리
        echo "--- Processing folder: $input ---"
        # find 명령어를 사용하여 *.jpg, *.jpeg, *.png 파일들을 재귀적으로 찾음
        find "$input" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | 
        while IFS= read -r -d $'\0' file; do
            process_file "$file"
        done
        echo "--- Folder processing complete: $input ---"
    elif [ -f "$input" ]; then
        # 파일인 경우: 해당 파일만 처리
        echo "--- Processing file: $input ---"
        process_file "$input"
        echo "--- File processing complete: $input ---"
    else
        echo "Warning: '$input' is not a valid file or directory. Skipping."
    fi
done

echo "All tasks finished."
