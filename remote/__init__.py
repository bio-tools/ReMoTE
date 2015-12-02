#!/usr/bin/env python
from lxml import etree
import json
import argparse
import requests
import os.path
import getpass
from requests.packages import urllib3

ns = {'btr':'http://biotoolsregistry.org'}

HOST = 'https://bio.tools'

SSL_VERIFY = False #verify SSL certificates

def auth(login):
    password = getpass.getpass()
    resp = requests.post(HOST + '/api/auth/login','{"username": "%s","password": "%s"}' % (login, password), headers={'Accept':'application/json', 'Content-type':'application/json'}, verify=SSL_VERIFY).text
    return json.loads(resp)['token']

def main():
    # 1. Import XML files from a Mobyle server or from a folder containing XML files
    # 2. Convert to BTR XML
    # 3. Convert to BTR JSON
    # 4. Register to Elixir BTR
    parser = argparse.ArgumentParser(
                 description='Transform Mobyle1 XML to BTR XML and JSON')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--from_server', help="Mobyle server URI to import definitions from")
    group.add_argument('--from_files', help="Mobyle XML files to import definitions from", nargs='+')
    parser.add_argument('--xml_dir', help="target directory for XML files")
    parser.add_argument('--login', help="registry login")
    args = parser.parse_args()
    if args.from_files:
        filenames = args.from_files
    elif args.from_server:
        resp = requests.get(args.from_server+'/net_services.py')
        services = json.loads(resp.text)
        filenames = []
        for key, value in json.loads(resp.text).items():
            filenames.append(value['url'])
    XSL_PATH = os.path.normpath(os.path.join(os.path.dirname(__file__),'remote.xsl'))
    xslt_doc = etree.parse(XSL_PATH)
    transform = etree.XSLT(xslt_doc)
    params = {'mobyle_root':"'http://mobyle.pasteur.fr'",
              'mobyle_contact':"'mobyle@pasteur.fr'"}
    if args.login:
        # Disable HTTPS verification warnings from urllib3
        # if setup requires it
        if SSL_VERIFY==False:
            urllib3.disable_warnings()
        print "authenticating..."
        token = auth(args.login)
        print "authentication ok"
        ok_cnt = 0
        ko_cnt = 0
        print "attempting to delete all registered services..."
        resp = requests.delete(HOST + '/api/tool/%s' % args.login, headers={'Accept':'application/json', 'Content-type':'application/json', 'Authorization': 'Token %s' % token}, verify=SSL_VERIFY)
    for filename in filenames:
        print "processing %s..." % filename
        mobyle_doc = etree.parse(filename)
        xml = transform(mobyle_doc, **params)
        btr_doc = xml
        resource_name = filename.split('/')[-1][0:-4]
        if args.xml_dir:
            xml_path = os.path.join(args.xml_dir, resource_name + '.xml')
            o_file =  open(xml_path, 'w')
            o_file.write(etree.tostring(xml, pretty_print=True))
            o_file.close()
        if args.login and args:
            resp = requests.post(HOST + '/api/tool', etree.tostring(xml, pretty_print=True), headers={'Accept':'application/json', 'Content-type':'application/xml', 'Authorization': 'Token %s' % token}, verify=SSL_VERIFY)
            if resp.status_code==201:
                print "%s ok" % resource_name
                ok_cnt += 1
            else:
                print "%s ko, error: %s" % (resource_name, resp.text)
                ko_cnt += 1
    if args.login:
        print "import finished, ok=%s, ko=%s" % (ok_cnt, ko_cnt)
