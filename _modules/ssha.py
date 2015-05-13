#!/usr/bin/env python

# http://www.openldap.org/faq/data/cache/347.html

import os
import hashlib
from base64 import encodestring as encode
from base64 import decodestring as decode

def b64e(string):
    return encode(string)[:-1]

def makeSecret(password,salt=None):
    if salt is None:
        salt = os.urandom(10)
    h = hashlib.sha1(password)
    h.update(salt)
    return "{SSHA}" + encode(h.digest() + salt)[:-1]

def checkPassword(challenge_password, password):
    challenge_bytes = decode(challenge_password[6:])
    digest = challenge_bytes[:20]
    salt = challenge_bytes[20:]
    hr = hashlib.sha1(password)
    hr.update(salt)
    return digest == hr.digest()
