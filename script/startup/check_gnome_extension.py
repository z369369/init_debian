import json, os, shutil, time, requests, re, os
from datetime import datetime
from bs4 import BeautifulSoup

if __name__ == '__main__':
    ext_path = '/home/lwh/git/linux_init/gnome-shell/extensions'
    a_ext_list = os.listdir(ext_path)
    a_version_all = []
    for item in a_ext_list:
        meta_file = ext_path + '/' + item + '/' + 'metadata.json'
        with open(meta_file, 'r') as f:
            data = json.load(f)
            a_item_version = data['shell-version']
            # Merge the arrays
            a_version_all = a_version_all + a_item_version
            
    # Convert the array to a set.
    a_version_all = set(a_version_all)

    # Convert the set back to a list.
    a_version_all = list(a_version_all)    
    a_version_all.sort()
    a_version_all.reverse()
    a_version_all = a_version_all[:5]
    
    # print(a_version_all)
    item_title = '|COL|'
    item_cotnent_save = ''

    for item in a_ext_list:
        meta_file = ext_path + '/' + item + '/' + 'metadata.json'
        item_title = item_title + item + '|'
        item_cotnent = '|' + item[:20] + '|'
        
        with open(meta_file, 'r') as f:
            data = json.load(f)
            a_item_version = data['shell-version']
            
            for a_ver in a_version_all:
                b_compa = ''
                if a_ver in a_item_version:
                    b_compa = 'O'

                item_cotnent = item_cotnent + b_compa + '|'

        item_cotnent_save = item_cotnent_save + item_cotnent + '\n'


    p_title = '|-|'
    for item in a_version_all:
        p_title = p_title + item + '|' 
        
    p_con = p_title + '\n'
    p_con = p_con + '|--|---|---|---|---|---|' + '\n'
    p_con = p_con + item_cotnent_save

    md_title = 'Linux GNOME Extension Compability'

    now = datetime.now()
    md_title_key = now.strftime("%Y-%m-%d %H:%M:%S")

    s_out = ''
    s_out = s_out + '---\r\n'
    s_out = s_out + 'date: ' + md_title_key + '\r\n'
    s_out = s_out + 'status: \r\n'
    s_out = s_out + 'alias: \r\n'
    s_out = s_out + 'tags: Linux\r\n'
    s_out = s_out + 'subs: Extension\r\n'
    s_out = s_out + '---\r\n'
    s_out = s_out + '\r\n'
    s_out = s_out + "# " + md_title + "\r\n\r\n"
    s_out = s_out + " 우분투 설치 계획\r\n\r\n"
    s_out = s_out + " GNOME 확장 프로그램 익스텐션 사용 가능 여부 확인 \r\n\r\n"
    s_out = s_out + " 의존성 dependency \r\n\r\n"
    
    s_out = s_out + p_con 
    
    with open('/home/lwh/phone/000_Personal/Linux/%s.md' % (md_title), 'w', encoding="utf-8") as out_file:
        out_file.write(s_out)
