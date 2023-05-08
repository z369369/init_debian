# -*- coding: utf-8 -*-

from __future__ import print_function
import httplib2
import os
import sys
import re
import time
from datetime import datetime
import random
import json
import logging
import redis 
from logging.handlers import RotatingFileHandler
from regex import P, R


import httpx
import xmlrpc.client
import config as c
import collections
import pprint
from collections import Counter

from apiclient import discovery
from oauth2client import client
from oauth2client import tools
from oauth2client.file import Storage
from oauth2client import service_account

from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow

from bs4 import BeautifulSoup
import psutil

try:
    import argparse
    flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
except ImportError:
    flags = None


APPLICATION_NAME = 'Drive API Python Quickstart'

def setup_logging(file_path, b_stream, log_path=''):
    logFile = ''
    if len(log_path) < 1:
        p = os.path.dirname(os.path.realpath(file_path))
        f = os.path.basename(file_path)    
        logFile = f'{p}/log/{f}.log'
    else:
        logFile = log_path

    log_formatter = logging.Formatter('%(asctime)s %(levelname)s %(funcName)s(%(lineno)d) %(message)s')
    my_handler = RotatingFileHandler(logFile, mode='a', maxBytes=5*1024*1024, backupCount=1, encoding=None, delay=0)
    my_handler.setFormatter(log_formatter)
    my_handler.setLevel(logging.INFO)
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(my_handler)
    if b_stream:
        streamHandler = logging.StreamHandler()
        logger.addHandler(streamHandler)    

def replace_common(o_title):
    
    title = o_title.upper()  
    title = re.sub(r'\【.*?\】|\『.*?\』|\<.*?\>|\[.*?\]|\[.*?\]|\(.*?\)|\「.*?\」|\（.*?\）', '', title)
    title = re.split(r'[0-9]{3,4}P', title, re.I)[0]
    title = re.split(r'[0-9]{6}', title, re.I)[0]
    title = re.split('WEBRIP|FHDRIP|HDRIP|DVDRIP|HDTV|BDRIP', title, re.I)[0]
    title = re.sub(r'\s2[0-9]{1,7}$', '', title)
    title = re.sub(r'[_….,~-]', ' ', title)
    
    title = title.strip()
    
    title = title.replace('.MP4', '')
    title = re.sub(' +', ' ', title)
    title = title.strip()
    
    if not re.search('S[0-9]{1,4}|E[0-9]{1,5}|[0-9]{1,5}회|[0-9]{4,6}', title):
        return o_title
    
    return title

def replace_kr(p_text_str):
    p_text_str = re.sub(r'\【.*?\】|\『.*?\』|\[.*?\]|\[.*?\]|\(.*?\)|\「.*?\」|\（.*?\）', '', p_text_str)
    if '.' in p_text_str:
        p_text_str = p_text_str.rsplit('.', 1)[0]
        
    p_text_str = re.split(r'-(.){0,1}', p_text_str)[0]

    p_text_str = re.sub('[_!,=#/?:@^&()+${}~]', '', p_text_str)
    p_text_str = re.split(r'S[0-9]{1,2}', p_text_str)[0]
    p_text_str = re.split(r'E[0-9]{1,5}|[0-9]{1,5}회|[0-9]{1,5}화|[0-9]{1,5}부', p_text_str)[0]

    p_text_str = re.split(r'[0-9]{6}', p_text_str)[0]
    p_text_str = re.split(r'COMPLETE|hdtv', p_text_str, flags=re.I)[0]

    p_text_str = re.sub('(KBS[0-9]{0,1}|SBS[0-9]{0,1}|MBC[0-9]{0,1}|JTBC[0-9]{0,1}|EBS[0-9]{0,1}|EVERY[0-9]{0,1})', '', p_text_str, flags=re.I)
    p_text_str = re.sub('(PICKX|MBN|TVN|MNET|OCN|UHD|채널A)','', p_text_str, flags=re.I)

    p_text_str = re.sub(r'20[0-9]{2}', '', p_text_str)
    p_text_str = p_text_str.replace("'", "")
    p_text_str = re.sub("[.]{1,3}", " ", p_text_str)

    p_text_str = re.sub(r'광복절기획|광복절특집|성탄기획|금토드라마|하이라이트', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'네트워크특선뮤직토크쇼|미니시리즈|일일연속극|대하드라마|주말드라마|월화드라마|수목드라마', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'송년기획|송년특집|설기획|설날특집|설날기획|성탄특집|설특집|납량특집|창사특집|신년특집|신년기획|성탄절기획|성탄절특집|추석기획|추석특집|주말특별기획|특별기획', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'앙코르|김병만의|합본|첫방송|드라마|외전|최종화|특집|스페셜', '', p_text_str, flags=re.I)
    
    p_text_str = re.sub(r"[0-9]{1,4}$", "", p_text_str)
    p_text_str = re.sub(u' end|시즌|완결', '', p_text_str)

    p_text_str = " ".join(p_text_str.split()[:4])
    p_text_str = p_text_str.strip()
    p_text_str = re.sub(r'[0-9]{1,9}$', '', p_text_str, flags=re.I)
    p_text_str = p_text_str.strip()

    return p_text_str


def replace_jp_drama(p_text_str):
    p_text_str = re.sub(r'\【.*?\】|\『.*?\』|\[.*?\]|\[.*?\]|\(.*?\)|\「.*?\」|\（.*?\）', '', p_text_str)
    
    if '.' in p_text_str:
        p_text_str = p_text_str.rsplit('.', 1)[0]

    p_text_str = re.split(r'([0-9]{4})', p_text_str)[0]
    p_text_str = re.sub(r'[0-9]{6}', '', p_text_str)
    p_text_str = re.sub('[#＃]', '', p_text_str)

    p_text_str = p_text_str.strip()
    p_text_str = p_text_str.replace("'", "")
    p_text_str = p_text_str.replace(" ", ".")
    p_text_str = re.sub(r"\.{2,9}", '.', p_text_str)
    
    p_text_str = re.split('-', p_text_str, flags=re.I)[0]
    # p_text_str = re.split(r'・|#|＃', p_text_str, flags=re.I)[0]

    p_text_str = re.split(r'[.]season(?i)', p_text_str, flags=re.I)[0]
    p_text_str = re.split(r'[.]complete(?i)', p_text_str, flags=re.I)[0]
    p_text_str = re.split('S\d(?i)', p_text_str, flags=re.I)[0]

    p_text_str = re.split(r'第[0-9]{1,5}', p_text_str)[0]
    p_text_str = re.split(r'EP[0-9]{1,5}|E[0-9]{1,5}', p_text_str, flags=re.I)[0]
    
    p_text_str = re.split(r'[0-9]{1,3}[.]{0,1}-[.]{0,1}[0-9]{1,3}', p_text_str, flags=re.I)[0]
    p_text_str = re.split(r'-(.){0,1}[0-9]{1,4}', p_text_str)[0]
    p_text_str = re.split(r'_(.){0,1}[0-9]{1,4}', p_text_str)[0]

    p_text_str = re.split(r'.WEEK.[0-9]{1,3}', p_text_str, flags=re.I)[0]

    p_text_str = re.sub(r'[0-9]{3,4}p', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'1ST|2ND|3RD|4TH|5TH', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'[_]|[.]{1,3}', '.', p_text_str)
    p_text_str = p_text_str.replace(".", " ")
    p_text_str = p_text_str.strip()
    p_text_str = p_text_str.title()

    p_text_str = " ".join(p_text_str.split()[:4])

    return p_text_str[:25]


def replace_jp_ani(p_text_str):
    p_text_str = re.sub(r'\【.*?\】|\『.*?\』|\[.*?\]|\[.*?\]|\(.*?\)|\「.*?\」|\（.*?\）', '', p_text_str)
    
    if '.' in p_text_str:
        p_text_str = p_text_str.rsplit('.', 1)[0]
    
    
    p_text_str = re.sub('First season|second season|third season|fourth season|fifth season|극장판|세컨드|시즌', '', p_text_str, flags=re.I)
    p_text_str = re.sub('1st|2nd|3rd|4th|5th', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'II|III|IV|VII|VIII|XI', '', p_text_str)

    p_text_str = re.split(r'v[0-9]{1,4}.*', p_text_str, flags=re.I)[0]
    p_text_str = re.sub(r'[0-9]{0,3}劇場版|特典映像|&amp;|한글|一般コミック|画集|XI|tver', '', p_text_str)

    p_text_str = re.split(r'[0-9]{4}.[0-9]{2}.[0-9]{2}', p_text_str)[0]
    p_text_str = re.sub(r' volumes [0-9]{1,4}-[0-9]{1,4}', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'v[0-9]{1,4}-[0-9]{1,4}', '', p_text_str, flags=re.I)
        
    p_text_str = re.sub('^.*.net-|^.*.net_|^.*.co-|^.*.one-|^.*.info_|^.*.top-|^.*.club-|^.*.su-', ' ', p_text_str, flags=re.I)
    
    p_text_str = re.sub(r'第.*巻|第.*話|第*部|全.*巻|全.*話', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r' [0-9]{0,4}巻', '', p_text_str, flags=re.I)

    p_text_str = re.sub(r'OP[0-9]{1,2}|EP[0-9]{1,2}|EP.[0-9]{1,2}|ED[0-9]{1,2}', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r' [0-9]{1,4}화', '', p_text_str)
    p_text_str = re.sub(r'파트 [0-9]{1,4}', '', p_text_str)
    p_text_str = re.sub(r' S[0-9]{1,2}', '', p_text_str)
    p_text_str = re.sub(r' v[0-9]{1,5}', '', p_text_str, flags=re.I)

    p_text_str = re.sub('[!`,=_#?@%^&♪・${}]|[+]|[.]', ' ', p_text_str)

    p_text_str = re.split(' - ', p_text_str, flags=re.I)[0]
    p_text_str = re.split(r'[0-9]{4}年', p_text_str)[0]
    p_text_str = re.split(r'[0-9]{1,4}月', p_text_str)[0]
    p_text_str = re.split(r'[0-9]{1,4}号', p_text_str)[0]
    p_text_str = re.split(r'-(.){0,1}[0-9]{1,4}', p_text_str)[0]
    p_text_str = re.split(r'-(.){0,1}TV', p_text_str)[0]
    p_text_str = re.split(r'-(.){0,1}OAD', p_text_str)[0]
    p_text_str = re.split(r'-(.){0,1}OND', p_text_str)[0]
    p_text_str = re.split(r'-(.){0,1}OAB', p_text_str)[0]
    p_text_str = re.split(r' [0-9]{1,4}기', p_text_str)[0]
    p_text_str = re.sub(r' vcol| Coloured| vol | movie', '', p_text_str, flags=re.I)

    p_text_str = re.sub(r'[0-9]{3,4}p', '', p_text_str, flags=re.I)
    p_text_str = re.split(' webrip', p_text_str, flags=re.I)[0]
    p_text_str = re.split(' part ', p_text_str, flags=re.I)[0]

    p_text_str = re.sub(' season|The Movie|BD-BOX|BD|CD| OAB| OVA| OAD| ONA| TVA| TV','', p_text_str, flags=re.I)
    p_text_str = re.sub(r'vol(.){0,1}[0-9]{1}', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'[0-9]{2,4}-[0-9]{2,4}', '', p_text_str, flags=re.I)
    p_text_str = re.sub(r'[-`:]', ' ', p_text_str)
    p_text_str = re.sub(r'\s{1,9}', ' ', p_text_str, flags=re.I)
    
    
    p_text_str = p_text_str.strip()
    p_text_str = " ".join(p_text_str.split()[:3])

    p_text_str = re.sub(r'[0-9]{1,9}$', '', p_text_str, flags=re.I)
        
    p_text_str = p_text_str.strip()
    p_text_str = " ".join(p_text_str.split()[:4])

    return p_text_str[:25]


def replace_us(p_text_str):
    p_text_str = re.sub(r'\【.*?\】|\『.*?\』|\[.*?\]|\[.*?\]|\(.*?\)|\「.*?\」|\（.*?\）', '', p_text_str)

    if '.' in p_text_str:
        p_text_str = p_text_str.rsplit('.', 1)[0]
        
    p_text_str = re.sub(r'[0-9]{1,4}-[0-9]{1,4}|[0-9]{1,4}~[0-9]{1,4}', '', p_text_str, flags=re.I)
    p_text_str = re.sub('[!,=#/?:@^&+$(){}]', '', p_text_str)
    p_text_str = re.sub('[_]', ' ', p_text_str)
    p_text_str = re.sub(r"\.{2,9}", '.', p_text_str)
    
    p_text_str = re.split('korean|spanish|japanese|russian|chinese|french|hindi|italian|english', p_text_str, flags=re.I)[0]
    p_text_str = re.split('UNCENSORED|censored|UNRATED|REMASTERED|Nondrm', p_text_str, flags=re.I)[0]

    p_text_str = re.split(r'.[0-9]{4}.',p_text_str)[0]

    p_text_str = re.split(r'[0-9]{3,4}p', p_text_str, flags=re.I)[0]
    p_text_str = re.split('webrip|fhdrip|hdrip|dvdrip|hdtv', p_text_str, flags=re.I)[0]

    p_text_str = re.split('[.]season(?i)', p_text_str, flags=re.I)[0]
    p_text_str = re.split('[.]complete(?i)', p_text_str, flags=re.I)[0]
    p_text_str = re.split('S\d(?i)', p_text_str, flags=re.I)[0]

    p_text_str = re.split(' - ', p_text_str, flags=re.I)[0]

    p_text_str = re.split('정품릴|시즌|완결|자막판|통합본|정식자막|초고화질|자체자막|고화질|UNCUT|무삭제|무삭제판|series|edition|complete|season', p_text_str, flags=re.I)[0]
    p_text_str = re.sub(r'[0-9]{1,5}회', '', p_text_str)
    p_text_str = re.sub(r'E[0-9]{1,5}', '', p_text_str, flags=re.I)
    
    p_text_str = re.sub(r'[0-9]{4}', '', p_text_str)
    p_text_str = re.sub(r'[0-9]{1}k', '', p_text_str)

    p_text_str = p_text_str.replace(".", " ")
    # p_text_str = " ".join(re.findall(r"[a-zA-Z]{3,}", p_text_str))
    p_text_str = p_text_str.strip()
    p_text_str = " ".join(p_text_str.split()[:4])


    p_text_str = p_text_str.strip()
    p_text_str = p_text_str.title()
    if len(p_text_str) > 10:
        p_text_str = re.sub(r'[0-9]{1,9}$', '', p_text_str, flags=re.I)
    
    p_text_str = " ".join(p_text_str.split()[:4])
    
    return p_text_str[:25]

def replace_hangul(p_text_str):
    p_text_str = re.sub('[a-zA-Z]', '', p_text_str)
    p_text_str = re.sub('[-=’]', '', p_text_str)
    p_text_str = p_text_str.strip()
    return p_text_str

def request_url(sUrl):
    req = httpx.get(sUrl)
    # html = req.text
    sResult = sUrl + " (" + str(req.status_code) + ")"
    logging.info(sResult)


def check_folder_exist(service, targetFolderId, p_hangul):
    hangul = p_hangul.replace("\\","\\\\")
    hangul = hangul.replace("'","\\'")
    results = service.files().list(
        q=f"'{targetFolderId}' in parents and mimeType = 'application/vnd.google-apps.folder' and name = '{hangul}' and trashed = false ",
        pageSize=5,
        orderBy="modifiedTime desc",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True,
        fields="nextPageToken, files(id, name)").execute()
    items = results.get('files', [])
    resultId = ''

    if not items:
        resultId = ''
    else:
        for item in items:
            resultId = item['id']
            break

    return resultId

def get_file_size(service, targetFolderId, hangul):
    results = service.files().list(
        q=f"'{targetFolderId}' in parents and name = '{hangul}' and trashed = false",
        pageSize=5,
        orderBy="modifiedTime desc",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True,
        fields="nextPageToken, files(id, name, quotaBytesUsed)").execute()
    items = results.get('files', [])
    resultSize = ''

    if not items:
        resultSize = ''
    else:
        for item in items:
            resultSize = item['quotaBytesUsed']

    return resultSize


def find_ani(search_text, p_lang, s_type):
    query = '''
    query ($page: Int = 1, $type: MediaType, $isAdult: Boolean = false, $search: String, $format: MediaFormat, $status: MediaStatus, $countryOfOrigin: CountryCode, $source: MediaSource, $season: MediaSeason, $year: String, $onList: Boolean, $yearLesser: FuzzyDateInt, $yearGreater: FuzzyDateInt, $licensedBy: [String], $includedGenres: [String], $excludedGenres: [String], $includedTags: [String], $excludedTags: [String], $sort: [MediaSort] = [SCORE_DESC, POPULARITY_DESC]) {
    Page(page: $page, perPage: 20) {
        pageInfo {
        total
        perPage
        currentPage
        lastPage
        hasNextPage
        }
        ANIME: media(type: $type, season: $season, format: $format, status: $status, countryOfOrigin: $countryOfOrigin, source: $source, search: $search, onList: $onList, startDate_like: $year, startDate_lesser: $yearLesser, startDate_greater: $yearGreater, licensedBy_in: $licensedBy, genre_in: $includedGenres, genre_not_in: $excludedGenres, tag_in: $includedTags, tag_not_in: $excludedTags, sort: $sort, isAdult: $isAdult) {
        id
        title {
            ''' + p_lang + '''
        }
        coverImage {
            large: extraLarge
            color
        }
        startDate {
            year
            month
            day
        }
        endDate {
            year
            month
            day
        }
        season
        type
        format
        status
        genres
        isAdult
        averageScore
        popularity
        mediaListEntry {
            status
        }
        nextAiringEpisode {
            airingAt
            timeUntilAiring
            episode
        }
        }
    }
    }
    '''

    variables = {
        'search': search_text,
        # 'season':'SPRING',
        # 'year':'2018%',
        # 'format[]': 'TV',
        'sort':'SEARCH_MATCH',
        'format[]' : 'MANGA',
        'format[]' : 'ONE_SHOT',
        'type': s_type,
        'page': 1,
        'perPage': 3
    }
    if s_type == 'ANIME':
        variables = {
            'sort':'SEARCH_MATCH',
            'search': search_text,
            # 'season':'SPRING',
            # 'year':'2018%',
            # 'format': 'TV',
            'type': s_type,
            'page': 1,
            'perPage': 3
        }        
    # print(search_text)
    # pprint.pprint(variables)
    p_title, p_year, p_cover, p_rating, p_genres = '', '', '', '', ''    
    try:
        url = 'https://graphql.anilist.co'
        response = httpx.post(url, json={'query': query, 'variables': variables})
        jsonString = json.loads(response.text) 
        # pprint.pprint(jsonString)
        jsonANIME = jsonString['data']['Page']['ANIME']
        if len(jsonANIME) >= 1:
            p_title = jsonANIME[0]['title'][p_lang] 
            p_year = jsonANIME[0]['startDate']['year']
            p_cover = jsonANIME[0]['coverImage']['large']
            p_rating = str(jsonANIME[0]['averageScore'])
            p_genres = str(",".join(jsonANIME[0]['genres']))
            
            logging.info(f"           [{p_lang} : {s_type}] = {search_text} -> {p_title}")
    except:
        pass    
    return {'year': p_year, 'title': p_title, 'cover' : p_cover, 'rating': p_rating, 'c' : 'JP', 'g' : p_genres}

# def find_imdb(search_title, s_title, n_search=True):
#     if re.search('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', search_title):
#         return {'search_title': search_title, 'imdb_id': '', 'title': '', 'year': '', 'cover': '', 'rating': '', 'g' : ''}
    
#     s_year = ''
#     if n_search:
#         s_year = ' ' + get_title_year(s_title)
    
#     opensubtitle_url = 'https://api.opensubtitles.org/xml-rpc'
#     server = xmlrpc.client.ServerProxy(opensubtitle_url)
#     token = server.LogIn(c.IMDB['user'], c.IMDB['password'],
#                             c.IMDB['charset'], c.IMDB['agent'])['token']  # Returns 2**3 = 8

#     logging.info(f"{opensubtitle_url} {search_title} {s_year}")

#     #################################
#     myArray = {"query": search_title + s_year }
#     aMovie = [
#         token,  # token
#         myArray
#     ]
#     result = server.SearchSubtitles(token, aMovie)
#     # pprint.pprint(result)

#     r_list = result['data']
#     a_imdb = []
#     for v in r_list:
#         a_imdb.append(v['IDMovieImdb'])

#     genre = ''

#     if len(a_imdb):
#         rating, cover, imdb_title, rel_year, poster, genre, p_country = '','','','','','',''
#         # print(len(a_imdb))
#         try:
#             counter = collections.Counter(a_imdb)
#             imdb_id = counter.most_common(1)[0][0]
#             logging.info(imdb_id)
#             result = server.GetIMDBMovieDetails(token, imdb_id)
#             # pprint.pprint(result)

#             if result:
#                 if 'data' in result:
#                     if 'cover' in result['data']:
#                         poster = result['data']['cover']

#                     if 'year' in result['data']:
#                         rel_year = result['data']['year']

#                     if 'title' in result['data']:
#                         imdb_title = result['data']['title']

#                     if 'cover' in result['data']:
#                         cover = result['data']['cover']

#                     if 'rating' in result['data']:
#                         rating = result['data']['rating']
#                         rating = str(int(float(rating) * 10))

#                     if 'country' in result['data']:
#                         p_country = ', '.join(result['data']['country']).upper()[:2]
#                         if p_country in c.T_C :
#                             p_country = c.T_C[p_country]
#                         if p_country != '' and p_country not in c.T_C :
#                             p_country = 'EU'
                        
#                     if 'genres' in result['data']:
#                         genre = ', '.join(result['data']['genres'])
#             imdb_id = 'tt' + imdb_id.zfill(7)

#             if token:
#                 result = server.LogOut(token)
#         except:
#             pass
        
#         return {'search_title': search_title, 'imdb_id': imdb_id, 'title': imdb_title, 'year': rel_year, 'cover': cover, 'rating': rating, 'g' : genre, 'c' : p_country}

#     return {'search_title': search_title, 'imdb_id': '', 'title': '', 'year': '', 'cover': '', 'rating': '', 'g' : ''}

def find_imdb2(search_title, s_title, n_search=True):
    if re.search('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', search_title):
        return {'search_title': search_title, 'imdb_id': '', 'title': '', 'year': '', 'cover': '', 'rating': '', 'g' : ''}
    
    s_year = ''
    if n_search:
        s_year = get_title_year(s_title)
    
    headers = {
        'Content-Type': "application/json",
        'Api-Key': "msEvaCLx7P8e1Teodv0qep3cWCp75IuS"
    }

    opensubtitle_url = 'https://api.opensubtitles.com/api/v1/features?type=movie&year='+s_year+ '&query=' + search_title 
    response = httpx.get(opensubtitle_url, headers=headers)
    result = None
    if len(response.text) > 10:
        result = json.loads(response.text)

    logging.info(f"{opensubtitle_url} ")
    
    print(result)
    #################################
    # print(result['total_count'])
    if result is not None and 'data' in result and len(result['data']) > 0:
        fAtt = result['data'][0]['attributes']
        # pprint.pprint(fObj)
        rating, cover, imdb_title, rel_year, genre, p_country, imdb_id, tmdb_id = '','','','','','','',''
        # print(len(fObj))
        try:
            if 'img_url' in fAtt:
                cover = fAtt['img_url']

            if 'year' in fAtt:
                rel_year = fAtt['year']

            if 'title' in fAtt:
                imdb_title = fAtt['title']

            if 'tmdb_id' in fAtt:
                tmdb_id = fAtt['tmdb_id']

            if 'imdb_id' in fAtt:
                imdb_id = fAtt['imdb_id']                

            # if 'rating' in fObj:
            #     rating = fObj['rating']
            #     rating = str(int(float(rating) * 10))

            # if 'country' in fObj:
            #     p_country = ', '.join(fObj['country']).upper()[:2]
            #     if p_country in c.T_C :
            #         p_country = c.T_C[p_country]
            #     if p_country != '' and p_country not in c.T_C :
            #         p_country = 'EU'
                
            # if 'genres' in fObj:
            #     genre = ', '.join(fObj['genres'])
            # # imdb_id = 'tt' + imdb_id.zfill(7)

        except:
            pass
        
        # return {'search_title': search_title, 'imdb_id': imdb_id, 'tmdb_id': tmdb_id,  'title': imdb_title, 'year': rel_year, 'cover': cover, 'rating': rating, 'g' : genre, 'c' : p_country}
        return {'search_title': search_title, 'imdb_id': imdb_id, 'tmdb_id': tmdb_id,  'title': imdb_title, 'year': rel_year, 'cover': cover}

    return {'search_title': search_title, 'imdb_id': '', 'imdb_id': '', 'title': '', 'year': ''}


def find_mdl(search_text, co ='1'):

    req_url = 'https://mydramalist.com/search?q=' + search_text + '&adv=titles&co='+ co + '&so=relevance'
    logging.info(req_url)
    p_title, p_year, p_cover, p_rating, s_href = '', '', '', '', ''
    
    req = httpx.get(req_url)
    html = req.text
    soup = BeautifulSoup(html, 'html.parser')

    div_style = soup.find_all('div', class_="m-t nav-active-border b-primary")

    for div in div_style:
        # pprint.pprint(div)
        try:
            p_title = div.find('a').text
            s_href = div.find('a').get('href')
            s_label = div.find('span', class_="text-muted").text
            p_cover = div.find('img')['data-src']
            p_year = re.search(r"(\d{4})", s_label).group(1)
        except:
            pass
        #######################################################
        req_url_2 = 'https://mydramalist.com' + s_href
        # logging.info(req_url_2)
        req_2 = httpx.get(req_url_2)
        html_2 = req_2.text
        soup_2 = BeautifulSoup(html_2, 'html.parser')
        # a = soup_2.find_all("a", href=re.compile(s_href))
        # for i in a:
        #     try:
        #         i_text = i.text

        #         if re.search(r"[一-龥]|[ぁ-ゔ]|[ァ-ヴー]|[々〆〤]", i_text):
        #             p_title = i_text
        #             break
                
        #     except:
        #         pass
        o_box = soup_2.find('div', 'show-detailsxss')#
        # Related Content
        p_title = ''
            
        if o_box is not None:
            if 'Related Content' in o_box.find('b').text:
                p_title = o_box.find('b').findNext('b').findNext('a').text
            else:
                p_title = o_box.find('b').findNext('a').text        
        
        
        logging.info(f"[find_mdl] / {p_year} / {p_title}")
        break

    return {'year': p_year, 'title': p_title, 'cover' : p_cover, 'rating': p_rating, 'c' : 'JP', 'g' : ''}

def byte_transform(bytes, to, bsize=1024):
    a = {'k' : 1, 'm': 2, 'g' : 3, 't' : 4, 'p' : 5, 'e' : 6 }
    r = float(bytes)
    for i in range(a[to]):
        r = r / bsize
    return r

def count_folder(service, p_id):
    a_folder = []
    n_folder= 0
    n_file = 0
    n_filesize = 0
    prevFolderId = p_id
    
    while True:
        page_token = None
        while True:            
            results = service.files().list(
                q=f"'{prevFolderId}' in parents and trashed = false",
                pageToken=page_token,
                pageSize=1000, fields="nextPageToken, files(id, name, mimeType, size)").execute()
            items = results.get('files', [])
            
            if items:
                for item in items:
                    cfid1 = item['id']
                    cfnm1 = item['name']
                    cfmime1 = item['mimeType']
                    cfsize1 = 0
                    if 'size' in item:
                        cfsize1 = int(item['size'])
                    
                    if cfid1 not in a_folder and cfmime1 == 'application/vnd.google-apps.folder':
                        a_folder.append(cfid1)
                        n_folder = n_folder + 1
                    else:
                        n_file = n_file + 1
                        n_filesize = n_filesize + cfsize1
                    
                    if n_filesize > 20 * 1024 * 1024 * 1024:
                        return n_folder, n_file, n_filesize
                    
                    # logging.info(f"{cfid1} {cfnm1} = {cfmime1}")


            page_token = results.get('nextPageToken', None)
            if page_token is None:
                break
        
        if len(a_folder) == 0:
            break
        else: 
            prevFolderId = a_folder.pop()
        
    return n_folder, n_file, n_filesize

def trash_dupl(service, p_id):
    a_folder = []
    n_folder= 0
    n_file = 0
    n_filesize = 0
    prevFolderId = p_id
    
    while True:
        page_token = None
        while True:
            results = service.files().list(
                q=f"'{prevFolderId}' in parents and trashed = false",
                orderBy="name asc",
                includeItemsFromAllDrives=True,
                supportsAllDrives=True,                   
                pageToken=page_token,
                pageSize=1000, fields="nextPageToken, files(id, name, mimeType, size)").execute()
            items = results.get('files', [])
            
            if items:
                a_dupl = {}
                for item in items:
                    cfid1 = item['id']
                    cfnm1 = item['name']
                    cfmime1 = item['mimeType']
                    
                    a_dupl[cfid1] = cfnm1
                    # if cfid1 not in a_folder and cfmime1 == 'application/vnd.google-apps.folder':
                    #     a_folder.append(cfid1)
                    
                for v1 in a_dupl:
                    for v2 in a_dupl:
                        if a_dupl[v1] == a_dupl[v2] and v1 != v2: 
                            logging.info('           Match Delete : ' + a_dupl[v1])  
                            a_dupl[v1] = ''
                            delete_file(service, v1)
                            break
                            
            page_token = results.get('nextPageToken', None)
            if page_token is None:
                break
        
        if len(a_folder) == 0:
            break
        else: 
            prevFolderId = a_folder.pop()
        
    return n_folder, n_file, n_filesize

def find_tmdb2(search_text, s_type, currentFileName):
    rObj2 = []
    if "JP_ANI" in s_type:
        rObj2 = find_ani(search_text, 'native', 'ANIME')
    elif "JP_MANGA" in s_type:
        # p_text = find_manga(search_text)
        rObj2 = find_ani(search_text, 'native', 'MANGA')
    elif "JP_DRAMA" in s_type:
        rObj2 = find_mdl(search_text, '1')
    elif "EN_MOVIE" in s_type:
        rObj2 = find_imdb2(search_text, currentFileName)
    else:
        rObj2 = {'year': '', 'title': '', 'cover' : '', 'rating': ''}
              
    return rObj2

def find_tmdb(search_text, p_type, s_title, n_search=True):
    s_type = 'tv'
    if 'movie' in p_type.lower():
        s_type = 'movie'
        
    n_year = ''
    if n_search:
        s_year = get_title_year(s_title)
        n_year = "&first_air_date_year=" + s_year

        if s_type == 'movie':
            n_year = "&year=" + s_year
    
    # print('--'+search_text+'--')  
    p_title = p_year = p_cover = p_rating = p_country = p_genre = tmdb_id = ''
    

      
    req_url = 'https://api.themoviedb.org/3/search/'+s_type+'?api_key=000b86b6d750224cdc3af7199afe0b06'+ n_year +'&language=ko-KR&page=1&include_adult=false&query=' + search_text
    logging.info(f"           {req_url}")
    try:
        response = httpx.get(req_url)
        jsonString = json.loads(response.text)
        r = jsonString['results']
 
        if len(r) >= 1:
            # r = sorted(r, key=lambda d: d['popularity'], reverse=True) 
            
            for item in r:
                if 'id' in item:
                    tmdb_id = item['id']
                if 'name' in item:
                    p_title = item['name']
                if 'first_air_date' in item:
                    p_year = item['first_air_date'][:4]            
                if 'title' in item:
                    p_title = item['title']
                if 'release_date' in item:
                    p_year = item['release_date'][:4] 
                if 'poster_path' in item and item['poster_path'] is not None:
                    p_cover = 'https://image.tmdb.org/t/p/original' + item['poster_path'] 
                if 'vote_average' in item:
                    p_rating = str(int(float(item['vote_average']) * 10))         
                
                logging.info(p_title)
                if 'origin_country' in item:
                    p_country = "".join(item['origin_country']).upper()[:2]      
                    p_country = p_country.upper()[:2]      
                    logging.info(f'BEFORE check....{p_country}')
                    
                    if p_country in c.T_C :
                        p_country = c.T_C[p_country]
                    elif p_country != '' and p_country not in c.T_C :
                        p_country = 'EU'
                                
                if p_country == '' and 'original_language' in item:
                    
                    p_country = item['original_language'].upper()[:2]   
                    logging.info(f'           Lang check = {p_country}')
                    
                    if p_country in c.T_C :
                        p_country = c.T_C[p_country]
                    elif p_country != '' and p_country not in c.T_C :
                        p_country = 'EU'
                            
                if 'genre_ids' in item:
                    a = []
                    for g in item['genre_ids']:
                        a.append(c.T_genres[g])
                    p_genre = ",".join(a)
                                                                      
                break
    except:
        pass
    
    return {'year': p_year, 'title': p_title, 'cover' : p_cover, 'rating': p_rating, 'c' : p_country, 'g' : p_genre, 'tmdb_id' : tmdb_id}

def get_file_count(service, targetFolderId, p_hangul):
    hangul = p_hangul.replace("\\","\\\\")
    hangul = hangul.replace("'","\\'")
    
    results = service.files().list(
        q=f"'{targetFolderId}' in parents and name contains '{hangul}' and trashed = false",
        pageSize=5,
        orderBy="modifiedTime desc",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True,
        fields="nextPageToken, files(id, name)").execute()
    items = results.get('files', [])
    resultId = ''
    
    r_cnt = 0

    if not items:
        resultId = ''
    else:
        r_cnt = len(items)

    return r_cnt

def check_file_exist(service, targetFolderId, p_hangul):
    hangul = p_hangul.replace("\\","\\\\")
    hangul = hangul.replace("'","\\'")
    
    results = service.files().list(
        q=f"'{targetFolderId}' in parents and name = '{hangul}' and trashed = false",
        pageSize=5,
        orderBy="modifiedTime desc",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True,
        fields="nextPageToken, files(id, name)").execute()
    items = results.get('files', [])
    resultId = ''

    if not items:
        resultId = ''
    else:
        for item in items:
            resultId = item['id']
            break

    return resultId

def check_file_exist_wtrash(service, targetFolderId, p_hangul):
    hangul = p_hangul.replace("\\","\\\\")
    hangul = hangul.replace("'","\\'")
    
    results = service.files().list(
        q=f"'{targetFolderId}' in parents and name = '{hangul}'",
        pageSize=5,
        orderBy="modifiedTime desc",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True,
        fields="nextPageToken, files(id, name)").execute()
    items = results.get('files', [])
    resultId = ''

    if not items:
        resultId = ''
    else:
        for item in items:
            resultId = item['id']
            break

    return resultId


def check_file_exist_me(service, p_hangul, eq='='):
    hangul = p_hangul.replace("\\","\\\\")
    hangul = hangul.replace("'","\\'")

    results = service.files().list(
        q=f"'me' in owners and name {eq} '{hangul}' and trashed = false",
        pageSize=5,
        orderBy="modifiedTime desc",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True,
        fields="nextPageToken, files(id, name)").execute()
    items = results.get('files', [])
    resultId = ''

    if not items:
        resultId = ''
    else:
        for item in items:
            resultId = item['id']
            break

    return resultId

def move_file(service, resultTargetFolderId, currentFileId):
    # Retrieve the existing parents to remove
    file = service.files().get(fileId=currentFileId,
                               supportsAllDrives=True,
                               fields='parents').execute()
    previous_parents = ",".join(file.get('parents'))
    # Move the file to the new folder
    file = service.files().update(fileId=currentFileId, 
                                  supportsAllDrives=True,
                                  addParents=resultTargetFolderId,
                                  removeParents=previous_parents,
                                  fields='id, parents').execute()


def update_prop(service, f_id, key, value):        
    file_metadata = {
        'properties': {
            key : value           
        }
    }
    
    file = service.files().update(fileId=f_id, 
                body=file_metadata,
                fields='id, parents,properties').execute()    

    return file

def update_star(service, cfid, b_star):
    file_metadata = {'starred': b_star}
    updated_file = service.files().update(fileId=cfid,body=file_metadata ).execute()

def trash(service, cfid2):
    file_metadata = {'trashed': True}
    file = service.files().update(fileId=cfid2, body=file_metadata, fields='id, parents').execute()    

def update_now(service, resultTargetFolderId, h_prop, description):
    current_int = datetime.now()
    c_time = current_int.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    
    file_metadata = { 'properties' : h_prop }
    file_metadata['modifiedTime'] = c_time

    if description is not None:
        file_metadata['description'] = description

    file = service.files().update(fileId=resultTargetFolderId, supportsAllDrives=True,
                                  body=file_metadata,
                                  fields='id, name, mimeType, properties').execute()

def rename(service, currentFileId, title):
    file_metadata = {
        'name': title
    }
    file = service.files().update(fileId=currentFileId, supportsAllDrives=True,
                                  body=file_metadata,
                                  fields='id, name, mimeType').execute()
    return file.get('id')


def delete_file(service, currentFileId):
    file = service.files().delete(fileId=currentFileId, supportsAllDrives=True).execute()
    return 'success'


def create_folder2(service, parent_folder_id, folder_name):
    folder_name = folder_name.replace("'","\'")
    file_metadata = {
        'name': folder_name,
        'description': 'DONOTDELETE',
        'parents': [parent_folder_id],
        'mimeType': 'application/vnd.google-apps.folder'
    }
    file = service.files().create(body=file_metadata, supportsAllDrives=True,
                                  fields='id').execute()

    return file.get('id')

def create_folder(service, parent_folder_id, folder_name):
    folder_name = folder_name.replace("'","\'")
    file_metadata = {
        'name': folder_name,
        'parents': [parent_folder_id],
        'mimeType': 'application/vnd.google-apps.folder'
    }
    file = service.files().create(body=file_metadata, supportsAllDrives=True,
                                  fields='id').execute()

    return file.get('id')


def create_folder_date(service, parent_folder_id, folder_name):
    folder_name = folder_name.replace("'","\'")
    file_metadata = {
        'name': folder_name,
        'modifiedTime': f"{folder_name}-01-01T01:00:00.000Z",
        'parents': [parent_folder_id],
        'mimeType': 'application/vnd.google-apps.folder'
    }
    file = service.files().create(body=file_metadata, supportsAllDrives=True,
                                  fields='id').execute()

    return file.get('id')

def create_folder_description(service, parent_folder_id, folder_name, description):
    folder_name = folder_name.replace("'","\'")
    file_metadata = {
        'name': folder_name,
        'description': description,
        'parents': [parent_folder_id],
        'mimeType': 'application/vnd.google-apps.folder'
    }
    file = service.files().create(body=file_metadata, supportsAllDrives=True,
                                  fields='id').execute()

    return file.get('id')

def get_service(account='5gentleman', s_name='drive'):
    secret_nm, scope_nm, cred_file = f'client_secret_{account}.json', c.SCOPES[account], f'cred_{account}.json'
    
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    
    credential_path = os.path.join(credential_dir, cred_file)
    secret_path = os.path.join(credential_dir, secret_nm)
    
    # logging.info(credential_path)
    store = Storage(credential_path)
    credentials = store.get()
    
    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(secret_path, scope_nm)
        flow.user_agent = APPLICATION_NAME
        if flags:
            credentials = tools.run_flow(flow, store, flags)
        else:  # Needed only for compatibility with Python 2.6
            credentials = tools.run(flow, store)

    http = credentials.authorize(httplib2.Http())
    service = discovery.build(s_name, 'v3', http=http, cache_discovery=False)
    return service

def create_event_string(event_name, st_time, end_time, remain_time=60, color_id=5):
    event = {
        'summary': event_name,
        'colorId': color_id,
        #   'location': '800 Howard St., San Francisco, CA 94103',
        #   'description': 'A chance to hear more about Google\'s developer products.',
        'start': {
            # 'dateTime': '2019-06-03T14:00:00-07:00',
            'dateTime': st_time,
            'timeZone': 'Asia/Seoul',
        },
        'end': {
            'dateTime': end_time,
            'timeZone': 'Asia/Seoul',
        },
        #   'recurrence': [
        #     'RRULE:FREQ=DAILY;COUNT=2'
        #   ],
        #   'attendees': [
        #     {'email': 'lpage@example.com'},
        #     {'email': 'sbrin@example.com'},
        #   ],
        'reminders': {
            'useDefault': False,
            'overrides': [
            #   {'method': 'email', 'minutes': 24 * 60},
            {'method': 'popup', 'minutes': remain_time},
            ],
        },
    }
    return event

def get_title_year(s_text):
    a = re.findall(r'\d+', s_text)
    # logging.info(a)
    
    r = str(datetime.today().year)
    for s_year in a:
        c_year = int(s_year)
        # logging.info(c_year)
        if c_year < 1900:
            continue
        
        if len(s_year) == 6:
            r = '20' + s_year[:2]
            # logging.info(f"match {r}")
            
            break
        if len(s_year) == 4 and c_year < int(r) + 2:
            r = s_year
            # logging.info(f"match {r}")
            break   
    
    if int(r) < 1900:
        r = str(datetime.today().year)

    return r
    
def insert_error_log(self, err_status, err_key = 'om_log', err_message=''):
    #목록 읽어와서 루프
    err_message = err_message.replace("'","")
    curr_time = datetime.now()
    log_seq =  35999999999999999999 - int(curr_time.strftime('%Y%m%d%H%M%S%f'))

    self.redis.lpush(f"{err_key}_list", log_seq)
    self.redis.ltrim(f"{err_key}_list", 0, 100)
    self.redis.hmset(f"{err_key}:" + str(log_seq), {'log_seq' : log_seq, 'stat' : err_status, 'title' : err_message, 'reg_dt' : curr_time.strftime('%Y-%m-%d %H:%M:%S')})		
    self.redis.expire(f"{err_key}:" + str(log_seq), 60*60*12)

def find_manga(s_word=""):
    p_name = s_word
    try:
        req_url = f"https://manga-zip.net/?s={s_word}"
        logging.info(f"request_url : {req_url}")
        req = httpx.get(req_url)

        html = req.text
        soup = BeautifulSoup(html, 'html.parser')
        div = soup.find("div",{"class":"posttext"})
        s_graph = div.find("p").text
        split_phrase = s_graph.split()
        # create counter object
        p_split = Counter(split_phrase)

        most_occured_words = p_split.most_common(4)
        
        p_name = most_occured_words[0][0]
    except:
        pass
    
    return p_name.strip()
    
def get_drive_translate(redis, req_text, lang_source='ja', lang_target='ko'):
    a_key = {
        'bSt6CJcEls1Rrn9jvDxF': 'asan4VjuVc',#계정1
        'utCMRG1j7myuasybD5Vu': 'xpLRGdoKX7',
        'ssVA2gDmHr6f589VQ_V6': 'ex6_fYRLbb',
        '4XjtGS_9D85_uw6jzy9L': 'TaoUApAhng',#계정1
        'ObfogDkVuZ1zBi6OyRQZ': 'EPd2CGU_9V',
        'UrctHR7vvOXCeFf1hT17': 'CXtOzJ8cpU',    
        'ifL3LHlOo_m_yxpAGDtt': '0QfltWVlfk',
        'k7SpGVt1Lt3MoaHqSmBm': 'rtYPAANLMI'
    }
    
    key_nm = 'list_drive_translate'
    if not redis.exists(key_nm):
        for k in a_key:
            # print(f"{k} - {v}")
            redis.lpush(key_nm, k)
        
        redis.expire(key_nm, 86400)    

    a_site = redis.lrange(key_nm, 0, 0)
    k_key = a_site[0].decode('utf-8')
    v_key = a_key[k_key]

    headers = {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        "X-Naver-Client-Id": k_key, 
        "X-Naver-Client-Secret": v_key
    }
    
    datas = {
        "source" : lang_source,
        "target" : lang_target,
        "text" : f"{req_text}"
    }
    req = httpx.post("https://openapi.naver.com/v1/papago/n2mt", headers=headers, data=datas)
    res = req.text
    r = json.loads(res)
    logging.info(r)

    r_text = ''
    if 'errorCode' in r and r['errorCode'] == "010":
        redis.lrem(key_nm, 0, k_key)   
        logging.info(f"{key_nm} DELETE {k_key}")
        raise Exception('translate limit exceed!') 
    else:
        r_text = r['message']['result']['translatedText']        
    
    return r_text       
    
def get_translate(redis, req_text, lang_source='ja', lang_target='ko'):
    a_key = {        
        'p1c3bDgyy4JGw_2X0ZdT': '9_x8hoxDdp',#계정2
        'WF35_RKFDnyPdKvjgf7e': 'ZO8hFCTJj2',
        'Ao_nrFh1nN7L1_u8jKo2': 'E7OYOIxLNu',
        'vzAKNVlDiGzpdzO0cjD8': 'eZN88PhvJd',                
        'ZD4j9coNd7tW71v2dNF5': '6LCgUNRYAp',
        'WNJPcE8iNmP8eBr5vHTE': 'aijiPKUqpR',
        'PEMlT5SNwnnVNADhqYin': 'B1fI3U7RwD',
        'Unf2zGyCxCOmIWubA3R9': 'zUjaiTDSJG',
        'jScx1qvLm4L70WfRAg2f': 'P9kqpSIf9m',
        'N4rumUv7QpfFA6Wl0fG6': '9ecbQovaSp'
    }
    
    key_nm = 'list_translate'
    if not redis.exists(key_nm):
        for k in a_key:
            # print(f"{k} - {v}")
            redis.lpush(key_nm, k)
        
        redis.expire(key_nm, 86400)    

    a_site = redis.lrange(key_nm, 0, 0)
    k_key = a_site[0].decode('utf-8')
    v_key = a_key[k_key]

    headers = {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        "X-Naver-Client-Id": k_key, 
        "X-Naver-Client-Secret": v_key
    }
    
    datas = {
        "source" : lang_source,
        "target" : lang_target,
        "text" : f"{req_text}"
    }
    req = httpx.post("https://openapi.naver.com/v1/papago/n2mt", headers=headers, data=datas)
    res = req.text
    r = json.loads(res)
    logging.info(r)

    r_text = ''
    if 'errorCode' in r and r['errorCode'] == "010":
        redis.lrem(key_nm, 0, k_key)   
        logging.info(f"{key_nm} DELETE {k_key}")
        raise Exception('translate limit exceed!') 
    elif 'errorCode' in r and r['errorCode'] == "N2MT05":
        r_text = req_text
    else:
        r_text = r['message']['result']['translatedText']        
    
    return r_text    

def get_youtube_url(redis, s_text, b_full=True):

    h_url = f"https://www.googleapis.com/youtube/v3/search?key={c.GOOGLE_KEY}&order=relevance&part=snippet&type=video&maxResults=1&q={s_text}"
    logging.info(f"                  [UTUBE] {s_text}")
    logging.info(f"                  [UTUBE] {h_url}")
    req = httpx.get(h_url)
    res = req.text
    r = json.loads(res)
    logging.info(r)
    y_url = ''
    
    if r is not None: 
        if 'items' in r  and len(r['items']) > 0 and 'id' in r['items'][0] and 'videoId' in r['items'][0]['id']:
            u_id = r['items'][0]['id']['videoId']
            if b_full:
                y_url = f'https://www.youtube.com/watch?v={u_id}'
            else:
                y_url = u_id
        elif 'error' in r and r['error']['code'] == 403:
            key_nm = 'stop_youtube'
            redis.set(key_nm, 1)   
            redis.expire(key_nm, 60*60*8)   
            raise Exception('youtube limit exceed!') 
    
    return y_url    

def get_adj():
    a_key = [
        '인기있는','재미있는','친근한','호감 가는','치유 되는',
        '고결한','현명한','슬기로운','솔직한','엄청난','공감 가는','잘 그린',
        '열정적인','진실된','사교적인','온화한','믿음직한 ','성실한',
        '웃기는','활기찬','상냥한','따뜻한','편안한','힐링되는',
        '친절한','다정한','행복한','희망적인', '즐거운', '긍정적인','이쁜',
        '쾌활한','지혜로운', '우아한','활동적인','좋아하는','사랑스러운',
        '유명한','센스 있는','감동 있는','신나는','유쾌한','로맨틱한','창의적인',
        '낭만적인','멋진','유익한','신기한','우와한','힐링 되는','귀여운','흥미 있는',
        '일상적인','꼭 봐야하는','보람찬','놀라운','어메이징한','최고의',''
        ]        
    random.shuffle(a_key)
    return a_key[0]

def get_youtube_search(type):
    a_key = {
        'JAPAN':    '豫告篇',
        'KOREA':    '예고편',
        'CHINA':    '豫告篇',
        'TAIWAN':   '豫告篇',
        'THAI':     'รถพ่วง'
    }   

    v_key = a_key[type]
    return v_key

def get_title_lang(type):
    a_key = {
        'JAPAN':    'ja',
        'KOREA':    'ko',
        'CHINA':    'zh-CN',
        'TAIWAN':   'zh-TW',
        'THAI':     'th'
    }   

    v_key = a_key[type]
    return v_key

def get_han_style(type):
    a_key = {
        'ANIME_TV':         '애니',
        'ANIME_MOVIE':      '극장판',
        'MANGA_MANGA':      '만화',
        'MANGA_NOVEL':      '라노벨'
    }   

    v_key = a_key[type]
    return v_key

def get_replace_news(o_text, c_split):
    while True:
        o_text = o_text.rsplit(c_split)[0]
        
        if(c_split not in o_text):
            break
        
    return o_text


def get_summary_text(o_content):
    o_content = o_content.replace("\r","")
    o_content = o_content.replace("\n","")
        
    o_content = re.sub(r'이미지 크게 보기', '', o_content)
    o_content = re.sub(r'\【.*?\】|\『.*?\』|\[.*?\]|\(.*?\)|\「.*?\」|\<.*?\>', '', o_content)
    
    o_content = get_replace_news(o_content, "▶")
    o_content = get_replace_news(o_content, "☞")
    o_content = get_replace_news(o_content, "Copy")
    o_content = get_replace_news(o_content, "news")
    o_content = get_replace_news(o_content, "osen")
    o_content = get_replace_news(o_content, "jQuery")
    o_content = get_replace_news(o_content, "css")
    

    o_content = re.sub(r'\S*@\S*\s?', '', o_content)
    o_content = re.sub(r'\S* 기자?', '', o_content)
    o_content = o_content.rsplit(".", 1)[0]
    o_content = o_content.strip()
    
    a_content = o_content.split('.')
    n_total = len(a_content)
    s_list = []
    n_minus = 0
    for index, s_content in enumerate(a_content):
        ri = random.randrange(0, 3)
        if ri > 0 and index != 0:
            s_list.append( s_content + ".")
        else:
            n_minus = n_minus + 1
        
    o_content = "".join(s_list)        
    return o_content, n_minus, n_total

def get_mix_content(o_content, a_img):
    a_content = o_content.split('.')
    a_img.reverse()
    n_total = len(a_content)
    s_list = []
    for index, s_content in enumerate(a_content):
        ri = random.randrange(0, 3)
        s_content = s_content.strip()
        if len(s_content) > 5:
            if ri == 0:
                s_list.append(f"<p>{s_content}.</p>")
                for img in a_img:
                    s = a_img.pop()
                    s_list.append(f"<p><center><img onerror=\"this.style.display='none';\" src=\"https://{s}\"></center></p>")     
                    break
            else:
                s_list.append(f"<p>{s_content}.</p>")
            
    for img in a_img:
        s_list.append(f"<p><center><img onerror=\"this.style.display='none';\" src=\"https://{img}\"></center></p>")     
            
    o_content = "".join(s_list)        
    return o_content

def get_mix_content2(o_content, a_img):
    a_content = o_content.split('.')
    a_img.reverse()
    n_total = len(a_content)
    s_list = []
    for index, s_content in enumerate(a_content):
        ri = random.randrange(0, 2)
        s_content = s_content.strip()
        if ri == 0:
            s_list.append(f"<p>{s_content}.</p>")
            for img in a_img:
                s = a_img.pop()
                s_list.append(f"<p><center><img onerror=\"this.style.display='none';\" src=\"{s}\"></center></p>")     
                break
        else:
            s_list.append(f"<p>{s_content}.</p>")
            
    for img in a_img:
        s_list.append(f"<p><center><img onerror=\"this.style.display='none';\" src=\"{img}\"></center></p>")     
            
    o_content = "".join(s_list)        
    return o_content

def check_process(processName='python3'):
    i = 0
    for proc in psutil.process_iter():
        if processName.lower() in proc.name().lower():
            i = i + 1    
    logging.info(f"process count = {i}")
    if i >= 5:
        logging.info(f"terminate count = {i}")
        os._exit(1)