#!/usr/bin/python3
# -*- coding: utf-8 -*-

########################################################################################
# @filename           :  zweek_filled.py
# @author             :  Copyright (C) Church.Zhong
# @date               :  2017-11-03
# @function           :  upgrade IP phone binary image file
# @see                :  C:\Program Files\Python36\Lib\urllib
# @require            :  python 3.6.2+
# @style              :  https://google.github.io/styleguide/pyguide.html
########################################################################################
import os
import time
import re
import subprocess
from datetime import datetime
from random import randint

import base64


import urllib.request
import urllib.parse
import urllib.error

def do_http_basic_auth(ip, username, password, filename):
    url = 'http://{0}{1}'.format(ip, '/mainform.cgi/Manu_Firmware_Upgrade.htm')
    userAndPass = base64.b64encode('{0}:{1}'.format(username, password).encode()).decode('utf-8')
    headers = {
        'Connection'        : 'keep-alive',
        'Authorization'     : 'Basic {0}'.format( userAndPass )
    }

    response = False
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print('GET {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    time.sleep( 1 )

    post = ('UPGRADESHOW=1')
    headers = {
        'Connection'        : 'keep-alive',
        'Content-Type'      : 'application/x-www-form-urlencoded',
        'Authorization'     : 'Basic {0}'.format( userAndPass ),
        'Content-Length'    : len(post)
    }
    data=post.encode('utf-8')

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print('POST {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    time.sleep( 1 )


    url = 'http://{0}{1}'.format(ip, '/upload.cgi')
    moment = datetime.now().strftime("%b%d%Y%H%M%S")
    boundary = '----WebKitFormBoundary{0}{1}'.format(moment, randint(0,9))
    print ('boundary=' + boundary)

    with open(filename, 'rb') as fd:
        image = fd.read()

    content = ("--%s\r\n" % boundary).encode('utf-8') + \
    ("Content-Disposition: form-data; name=\"localupgrade\"\r\n\r\n20").encode('utf-8') + \
    ("\r\n--%s\r\n" % boundary).encode('utf-8') + \
    ("Content-Disposition: form-data; name=\"upname\"; filename=\"%s\"\r\n" % filename).encode('utf-8') + \
    ("Content-Type: application/octet-stream\r\n\r\n").encode('utf-8') + \
    image + \
    ("\r\n--%s--\r\n" % boundary).encode('utf-8')
    data = content

    headers = {
        'Content-Type'      : 'multipart/form-data; boundary=%s' % boundary,
        'Authorization'     : 'Basic {0}'.format( userAndPass ),
        'Connection'        : 'keep-alive',
        'Content-Length'    : len(content)
    }
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print('POST {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))


    return response


def do_http_cookie_pair(ip, username, password, filename):
    url = 'http://{0}{1}'.format(ip, '/mainform.cgi?go=mainframe.htm')
    headers = {
        'Connection'        : 'keep-alive',
        'Cookie'            : 'session=',
    }

    response = False
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print('GET {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    time.sleep( 1 )

    url = 'http://{0}{1}'.format(ip, '/mainform.cgi/login_redirect.htm')
    headers = {
        'Connection'        : 'keep-alive',
        'Cookie'            : 'session=',
    }

    response = False
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print('GET {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))


    time.sleep( 1 )

    url = 'http://{0}{1}'.format(ip, '/login.cgi')
    headers = {
        'Connection'        : 'keep-alive',
        'Cookie'            : 'session=',
    }

    response = False
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print('GET {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))


    time.sleep( 1 )


    url = 'http://{0}{1}'.format(ip, '/login.cgi')
    b64password = base64.b64encode('{}'.format( password ).encode()).decode('utf-8')
    post = { 'user' : username, 'psw' : b64password }
    data = urllib.parse.urlencode(post).encode('utf-8')
    headers = {
        'Content-Type'      : 'application/x-www-form-urlencoded',
        'Connection'        : 'keep-alive',
        'Cookie'            : 'session='
    }

    SetCookie = ''
    response = False
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data ) as f:
            pass
            print('POST {0},{1},{2}'.format(url, f.status, f.reason))
            cookie = f.info()['Set-Cookie']
            print('Set-Cookie: {}'.format( cookie ))
            m = re.match(r'^session=(.*)\;\ path\=\/$', cookie)
            if not m:
                response = False
            else:
                SetCookie = m.group(1)
                print('got shiny SetCookie={}'.format( SetCookie ))
                #page = f.read().decode(encoding='utf-8')
                response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))



    time.sleep( 1 )



    url = 'http://{0}{1}'.format(ip, '/mainform.cgi/Manu_Firmware_Upgrade.htm')
    b64password = base64.b64encode('{}'.format( password ).encode()).decode('utf-8')
    headers = {
        'Connection'        : 'keep-alive',
        'Cookie'            : 'session={}'.format( SetCookie )
    }

    response = False
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print('POST {0},{1},{2}'.format(url, f.status, f.reason))
            print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))



    time.sleep( 1 )



    post = ('UPGRADESHOW=1')
    headers = {
        'Connection'        : 'keep-alive',
        'Content-Type'      : 'application/x-www-form-urlencoded',
        'Cookie'            : 'session={}'.format( SetCookie ),
        'Content-Length'    : len(post)
    }
    data=post.encode('utf-8')

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print('POST {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))



    time.sleep( 1 )



    url = 'http://{0}{1}'.format(ip, '/upload.cgi')
    moment = datetime.now().strftime("%b%d%Y%H%M%S")
    boundary = '----WebKitFormBoundary{0}{1}'.format(moment, randint(0,9))
    print ('boundary=' + boundary)

    with open(filename, 'rb') as fd:
        image = fd.read()

    content = ("--%s\r\n" % boundary).encode('utf-8') + \
    ("Content-Disposition: form-data; name=\"localupgrade\"\r\n\r\n20").encode('utf-8') + \
    ("\r\n--%s\r\n" % boundary).encode('utf-8') + \
    ("Content-Disposition: form-data; name=\"upname\"; filename=\"%s\"\r\n" % filename).encode('utf-8') + \
    ("Content-Type: application/octet-stream\r\n\r\n").encode('utf-8') + \
    image + \
    ("\r\n--%s--\r\n" % boundary).encode('utf-8')
    data = content

    headers = {
        'Content-Type'      : 'multipart/form-data; boundary=%s' % boundary,
        'Cookie'            : 'session={}'.format( SetCookie ),
        'Connection'        : 'keep-alive',
        'Content-Length'    : len(content)
    }
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print('POST {0},{1},{2}'.format(url, f.status, f.reason))
            #print(f.info())
            #page = f.read().decode(encoding='utf-8')
            response = True
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))



    return response




# https://pymotw.com/3/argparse/
import argparse

def work():
    parser = argparse.ArgumentParser()

    parser.add_argument('-i', action='store',
                    default='172.17.179.100',
                    dest='ip_address',
                    help='Set HTTP ip_address for IPP')

    parser.add_argument('-u', action='store',
                    default='admin',
                    dest='username',
                    help='Set HTTP username for IPP')

    parser.add_argument('-p', action='store',
                    default='1234',
                    dest='password',
                    help='Set HTTP password for IPP')

    parser.add_argument('-f', action='store',
                    default='',
                    dest='image_file',
                    help='Set image binary file for IPP')

    parser.add_argument('-n', action='store_true',
                    default=False,
                    dest='nonLync',
                    help='Upgrade nonlync or SFB branch')

    parser.add_argument('--version', action='version',
                    version='%(prog)s 1.0')

    results = parser.parse_args()
    print('ip_address       = {!r}'.format(results.ip_address))
    print('username         = {!r}'.format(results.username))
    print('password         = {!r}'.format(results.password))
    print('image_file       = {!r}'.format(results.image_file))
    print('nonLync          = {!r}'.format(results.nonLync))
    if True == results.nonLync:
        print ("upgrade nonLync image!\n")
        do_http_basic_auth(results.ip_address, results.username, results.password, results.image_file)
    else:
        print ("upgrade SFB/Lync image!\n")
        do_http_cookie_pair(results.ip_address, results.username, results.password, results.image_file)

def main():
    start = time.time()
    work()
    print('running time:%s' % (time.time() - start))

if __name__ == "__main__":
    main()