#!/usr/bin/python3
# -*- coding: utf-8 -*-



########################################################################################
# @filename           :  zweek_filled.py
# @author             :  Copyright (C) Church.Zhong
# @date               :  2017-11-03
# @function           :  http://aclactitime/user/submit_tt.do?dateStr=20171103
# @see                :  C:\Program Files\Python36\Lib\urllib
# @require            :  python 3.6.2+
# @style              :  https://google.github.io/styleguide/pyguide.html

########################################################################################


import urllib.request
import urllib.parse
import urllib.error
import http.cookiejar




cookies=''
def get_cookies():
    #10.1.1.123
    url = r'http://aclactitime/frontRedirector.do'

    headers = {
        'Host': 'aclactitime',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': 1,
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'DNT': 1,
        'Referer': 'http://aclactitime/',
        #'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        'Cookie': 'JSESSIONID=sorw9mm79z8e; cookies=true',
    }

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            c = str(f.info())
            index = c.index('JSESSIONID=')+len('JSESSIONID=')
            cookies = c[index:(index+13)]
            print("cookies=", cookies)
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    return page




def get_login():
    #10.1.1.123
    url = r'http://aclactitime/login.do'

    headers = {
        'Host': 'aclactitime',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': 1,
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'DNT': 1,
        'Referer': 'http://aclactitime/',
        #'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        'Cookie': 'JSESSIONID=sorw9mm79z8e; cookies=true',
    }

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req ) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            c = str(f.info())
            index = c.index('JSESSIONID=')+len('JSESSIONID=')
            cookies = c[index:(index+13)]
            print("cookies=", cookies)
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    return page






def open_url(auth, url, referer):
    #10.1.1.123
    postdata = ''
    headers = {
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063',
        'Content-type': 'text/plain',
        'Host': 'aclactitime',
        'Connection': 'Keep-Alive',
    }

    if (referer != ''):
        headers['Referer'] = referer
    if (auth != ''):
        headers['Content-Length'] = len(auth)
        data=auth.encode('utf-8')
    if (cookies != ''):
        headers['Cookie'] = 'JSESSIONID=' + cookies + r'; cookies=true'

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    return page
########################################################################################



def get_challenge():
    #10.1.1.123
    url = r'http://aclactitime/rpc'
    post = ('{'+ 
        'id:2,'+ 
        'method:"LoginService.getChallenge",'+ 
        'params:[]'+ 
    '}')


    headers = {
        'Host': 'aclactitime',
        'Connection': 'keep-alive',
        'Origin': 'http://aclactitime',
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36',
        'Content-type': 'text/plain',
        'Accept': '*/*',
        'DNT': 1,
        'Referer': 'http://aclactitime/login.do',
        #'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN,zh;q=0.9',
    }
    if (cookies != ''):
        headers['Cookie'] = 'JSESSIONID=' + cookies + r'; cookies=true'
    if (post != ''):
        headers['Content-Length'] = len(post)
        data=post.encode('utf-8')

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))


    try:
        d = eval(page)
        challengeValue = d['result']['challengeValue']
    except KeyError as e:
        print(e.code())

    return challengeValue


########################################################################################

user_name = 'churchz'
user_password = '123456'
def get_user_name():
    return user_name

def get_user_password():
    return user_password




########################################################################################
import hashlib
def create_md5(str):
    m = hashlib.md5()
    m.update(str)
    return m.hexdigest()

def get_password_md5():
    name = get_user_name().lower()
    password = get_user_password()
    md5UserPassword = create_md5(password.encode("utf-8"))
    challengeValue = get_challenge()
    print(challengeValue)

    salt = (md5UserPassword + challengeValue + name)
    md5SaltUserPassword=create_md5( salt.encode("utf-8") )
    print ('[md5SaltUserPassword]', md5SaltUserPassword)
    return md5SaltUserPassword

# password=d39e7bc95b033c1201cbf7ca88eb143b&submitted=1&username=churchz&pwd=
def get_login_password_data():
    md5 = get_password_md5()
    name = get_user_name().lower()
    #password=dccdb6b89339f19ec311075d73b9bfa5&submitted=1&username=churchz&pwd=&remember=on
    data = ('password=' + md5 +'&submitted=1&username=' + name + '&pwd=')
    return data
########################################################################################

def do_login(auth):
    #10.1.1.123
    url = r'http://aclactitime/login.do'

    headers = {
        'Host': 'aclactitime',
        'Connection': 'keep-alive',
        'Cache-Control': 'max-age=0',
        'Origin': 'http://aclactitime',
        'Upgrade-Insecure-Requests': 1,
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'DNT': 1,
        'Referer': 'http://aclactitime/login.do',
        #'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN,zh;q=0.9',
    }
    if (auth != ''):
        headers['Content-Length'] = len(auth)
        data=auth.encode('utf-8')
    if (cookies != ''):
        headers['Cookie'] = 'JSESSIONID=' + cookies + r'; cookies=true'


    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    return page

def do_submit(auth,today):
    #10.1.1.123
    url = r'http://aclactitime/user/submit_tt.do'
    post = ('submitted=true&dateStr=' + today +
   '&pageAction=addTasks&addTaskList=' + str(130) + '&deletedTaskList=&autoAssignProjects=false&redirectUrl=&formDataModified=false&afterReloginUrl=&beforeReloginUsername=&taskToReopen=-1&editTaskId=-1&containsLeaves=false')

    headers = {
        'Host': 'aclactitime',
        'Connection': 'keep-alive',
        'Cache-Control': 'max-age=0',
        'Origin': 'http://aclactitime',
        'Upgrade-Insecure-Requests': 1,
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'DNT': 1,
        'Referer': 'http://aclactitime/user/submit_tt.do?dateStr=' + today,
        #'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN,zh;q=0.9',
    }
    if (post != ''):
        headers['Content-Length'] = len(post)
        data=post.encode('utf-8')
    if (cookies != ''):
        headers['Cookie'] = 'JSESSIONID=' + cookies + r'; cookies=true'


    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    return page



def get_time_list(auth, day):
    #10.1.1.123
    url = (r'http://aclactitime/user/submit_tt.do?dateStr=' + day)

    headers = {
        'User-Agent': r'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063',
        'Referer': r'http://aclactitime/login.do',
        'Content-type': 'text/plain',
        'Host': 'aclactitime',
        'Connection': 'Keep-Alive',
    }
    if (auth != ''):
        headers['Content-Length'] = len(auth)
        data=auth.encode('utf-8')
    if (cookies != ''):
        headers['Cookie'] = 'JSESSIONID=' + cookies + r'; cookies=true'

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, data=data) as f:
            pass
            print(f.status)
            print(f.reason)
            print(f.info())
            page = f.read().decode(encoding='utf-8')
    except urllib.error.HTTPError as e:
        print(e.code())
        print(e.read().decode(encoding='utf-8'))

    with open("time_list.html", 'w', encoding='utf8') as file:
        file.write(page)
        file.close()

    return 0

import time
from datetime import date


#http://aclactitime/user/submit_tt.do?dateStr=20171025
def main():
    today = date.today().strftime("%Y%m%d")
    print ("today", today)

    print('11111111');
    get_cookies()
    print('22222');
    get_login()
    print('3333');
    authority = get_login_password_data()
    print('44');
    do_login(authority)
    print('55');
    #get_time_list(authority, today)
    do_submit(authority, '20180121')
    print('666');
    return 0


if __name__ == "__main__":
    main()


########################################################################################