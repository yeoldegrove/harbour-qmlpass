#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright (C) 2017  Eike Waldt
# Contact: jolla@yeoldegrove.de
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import pyotherside
import subprocess
from subprocess import Popen, PIPE

class passwordstore():
    def search(*args):
        inputs = list(args)
        output = []
        for input in inputs:
            # find all files matching input and end with .gpg
            cmd = "find /home/nemo/.password-store -iname '*" + input + "*.gpg'"
            p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
            out, err = p.communicate()
            # replace some strings (homedir, .gpg)
            out_replace = out.decode('utf-8').replace('/home/nemo/.password-store/','').replace('.gpg','')
            # split result on newlines to get a list
            out_list = out_replace.split('\n')
            # remove empty list items
            out_list = [ x for x in out_list if "" != x ]
            output.append(out_list)
        # flaten the list (as we might have a sublist for each 'input'
        output = [item for sublist in output for item in sublist]
        return output[:]

    def show_login(input):
        output = []
        print("input: " + input)
        # find all files matching input and end with .gpg
        cmd = "pass show " + input + " | grep '^login:'"
        print(cmd)
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('login: ','')
        output = out_replace
        return output

    def show_pass(input):
        output = []
        print("input: " + input)
        # find all files matching input and end with .gpg
        cmd = "pass show " + input + " | head -1"
        print(cmd)
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        # comment in for debugging, elsewise pw is in cleartext in debug log
        # pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('login: ','')
        output = out_replace
        return output

    def show_url(input):
        output = []
        # find all files matching input and end with .gpg
        cmd = "pass show " + input + " | grep '^url:'"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('url: ','')
        output = out_replace
        return output

    def git_pull():
        output = []
        # find all files matching input and end with .gpg
        cmd = "cd  /home/nemo/.password-store && git pull"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('url: ','')
        output = out_replace
        return output
