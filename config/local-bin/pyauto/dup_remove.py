import os
import difflib
import time
from pathlib import Path

def clean_similar_files(folders, threshold=0.5, dry_run=True):
    """
    지정된 폴더들에서 파일명을 비교하여
    유사도가 threshold 이상일 경우 오래된 파일을 삭제하는 함수.

    :param folders: 여러 개의 폴더 경로
    :param threshold: 유사도 기준 (0.5 = 50%)
    :param dry_run: True일 경우 실제 삭제하지 않고 미리보기만 함
    """
    files = []

    # 폴더별 파일 수집
    for folder in folders:
        p = Path(folder)
        if not p.exists() or not p.is_dir():
            print(f"[경고] {folder} 는 올바른 폴더가 아님")
            continue

        for f in p.iterdir():
            if f.is_file():
                files.append({
                    "path": f,
                    "name": f.name,
                    "mtime": f.stat().st_mtime  # 수정시간
                })

    # 파일 비교
    checked = set()
    for i, f1 in enumerate(files):
        for j, f2 in enumerate(files):
            if i >= j:
                continue

            key = tuple(sorted([f1["path"], f2["path"]]))
            if key in checked:
                continue
            checked.add(key)

            ratio = difflib.SequenceMatcher(None, f1["name"], f2["name"]).ratio()

            if ratio >= threshold:
                # 오래된 파일 찾기
                older = f1 if f1["mtime"] < f2["mtime"] else f2
                newer = f2 if older is f1 else f1

                print(f"[유사도 {ratio:.2f}] {older['name']} -> {newer['name']}")
                print(f" → 오래된 파일 삭제 대상: {older['path']}")

                if not dry_run:
                    try:
                        os.remove(older["path"])
                        print("   삭제 완료")
                    except Exception as e:
                        print(f"   삭제 실패: {e}")

def get_non_hidden_subdirectories(base_paths):
    all_subdirs = []
    
    for base_path in base_paths:
        if not os.path.isdir(base_path):
            print(f"경고: 기본 경로를 찾을 수 없습니다: {base_path}")
            continue

        for root, dirs, files in os.walk(base_path):
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            all_subdirs.append(root)

    return all_subdirs

if __name__ == "__main__":
    base_paths_to_search = [
        '/home/lwh/Downloads/Download_phone/linux',
        '/home/lwh/Downloads/Download_phone/android'
    ]

    result_array = get_non_hidden_subdirectories(base_paths_to_search)
    # 예시 사용법
    
    clean_similar_files(
        result_array,
        threshold=0.6,
        dry_run=False   # 실제 삭제하려면 False 로 변경
    )
