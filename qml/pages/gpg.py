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
import os
import re

class gpg():
    def list_uids():
        output = []
        # find all gpg uids for all secret keys
        cmd = "gpg2 -K | grep uid | cut -d']' -f2 | sed 's/^ //g'"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # split result on newlines to get a list
        uids = out.decode('utf-8').split('\n')
        # remove empty list items
        uids = [ x for x in uids if "" != x ]
        print(uids)
        for uid in uids:
            print(uid)
            uid_cached = gpg.get_cached(uid).decode('utf-8') + " - " + uid
            print(uid_cached)
            output.append(uid_cached)
        return output[:]

    def get_cached(uid):
        # find all gpg uids for all secret keys
        cmd = "echo \"KEYINFO --no-ask $(gpg2 --fingerprint --with-keygrip \"" + uid + "\" | grep Keygrip | head -1 | cut -d'=' -f2 |sed 's/ //g') Err Pmt Des\" | gpg-connect-agent | grep '\ 1\ P' >/dev/null; if [ $? -eq   0 ]; then echo cached; else echo uncached; fi"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        out = out.strip()
        return(out)

    def cache_uid(uid, passphrase):
        pyotherside.send('stdout', uid)
        pyotherside.send('stdout', passphrase)
        # set the passphrase for a specific UID
        cmd = "python3 -c \"import binascii; print(binascii.hexlify(b'" + passphrase + "'))\"|cut -d\"'\" -f2"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        hexpw = out.decode('utf-8')
        cmd = "gpg2 --with-keygrip -K --fingerprint \"" + uid + "\"|grep Keygrip|cut -d'=' -f2|sed 's/ //g'"
        pyotherside.send('stdout', cmd)
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        keygrips = out.decode('utf-8').split("\n")
        pyotherside.send('stdout', keygrips)
        for keygrip in keygrips:
            pyotherside.send('stdout', keygrip)
            cmd = "gpg-connect-agent -q \"PRESET_PASSPHRASE " + keygrip + " -1 " + hexpw + "\" /bye"
            p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
            out, err = p.communicate()
            pyotherside.send('stdout', out)
            pyotherside.send('stderr', err)

    def create_start_gpg_agent_file():
        # create start-gpg-agent.sh script to run at login
        config_dir = "~/.config/harbour-qmlpass"
        if not os.path.exists(config_dir):
            os.makedirs(config_dir)
        start_gpg_agent_file = open(config_dir + "/start-gpg-agent.sh","w")
        start_gpg_agent_content = [
            "#!/bin/bash\n",
            "GPG_TTY=$(tty)\n",
            "export GPG_TTY\n",
            "ps -fu $USER | grep \"gpg-agen[t]\" 2>&1 >/dev/null\n",
            "if [ $? -ne 0 ]; then\n",
            "  eval \"$(gpg-agent --daemon --enable-ssh-support)\"\n",
            "fi\n",
            "export GPG_AGENT_INFO\n",
            "export SSH_AUTH_SOCK"
        ]
        start_gpg_agent_file.writelines(start_gpg_agent_content)
        start_gpg_agent_file.close()
        # add start-gpg-agent.sh to .bashrc
        if not "source ~/.config/harbour-qmlpass/start-gpg-agent.sh" in open('~/.bashrc').read():
            bashrc_file = open("~/.bashrc","a")
            bashrc_file.write("source ~/.config/harbour-qmlpass/start-gpg-agent.sh\n")
            bashrc_file.close()

    def create_default_agent_config():
        gpg.create_start_gpg_agent_file()
        # create .gnupg/gpg-agent.conf
        gpg_dir = "~/.gnupg"
        if not os.path.exists(gpg_dir):
            os.makedirs(config_dir)
        gpg_agent_conf_file = "~/.gnupg/gpg-agent.conf"
        gpg_agent_conf = open(gpg_agent_conf_file,"w")
        gpg_agent_conf_content = [
            "default-cache-ttl 10800\n",
            "max-cache-ttl 10800\n",
            "enable-ssh-support\n",
            "allow-preset-passphrase\n"
        ]
        gpg_agent_conf.writelines(gpg_agent_conf_content)
        gpg_agent_conf.close()

    def reset_default_agent_config():
        gpg.create_start_gpg_agent_file()
        # reset default in .gnupg/gpg-agent.conf
        gpg_dir = "~/.gnupg"
        if not os.path.exists(gpg_dir):
            os.makedirs(config_dir)
        gpg_agent_conf_file = "~/.gnupg/gpg-agent.conf"
        # reset default vaules where values
        with open(gpg_agent_conf_file,"r") as file :
            gpg_agent_conf_content = file.read()
        gpg_agent_conf_content = re.sub("default-cache-ttl.*","default-cache-ttl 10800", gpg_agent_conf_content)
        with open(gpg_agent_conf_file,"w") as file :
            gpg_agent_conf_content = file.write(gpg_agent_conf_content)
        with open(gpg_agent_conf_file,"r") as file :
            gpg_agent_conf_content = file.read()
        gpg_agent_conf_content = re.sub("max-cache-ttl.*","max-cache-ttl 10800", gpg_agent_conf_content)
        with open(gpg_agent_conf_file,"w") as file :
            gpg_agent_conf_content = file.write(gpg_agent_conf_content)
        # attach parameter if not present
        gpg_agent_conf = open(gpg_agent_conf_file, "a")
        if not "default-cache-ttl" in open(gpg_agent_conf_file).read():
            gpg_agent_conf.write("\ndefault-cache-ttl 10800")
        if not "max-cache-ttl" in open(gpg_agent_conf_file).read():
            gpg_agent_conf.write("\nmax-cache-ttl 10800")
        if not "enable-ssh-support" in open(gpg_agent_conf_file).read():
            gpg_agent_conf.write("\nenable-ssh-support")
        if not "allow-preset-passphrase" in open(gpg_agent_conf_file).read():
            gpg_agent_conf.write("\nallow-preset-passphrase")
        gpg_agent_conf.close()

    def read_agent_config():
        gpg_agent_conf_file = "~/.gnupg/gpg-agent.conf"
        with open(gpg_agent_conf_file, 'r') as gpg_agent_conf_file_content:
            content = gpg_agent_conf_file_content.read()
        pyotherside.send('stdout', content)
        return content

    def write_agent_config(input):
        gpg_agent_conf_file = "~/.gnupg/gpg-agent.conf"
        with open(gpg_agent_conf_file, 'w') as gpg_agent_conf_file_content:
            gpg_agent_conf_file_content.write(input)

    def kill_agent():
        # find all gpg uids for all secret keys
        cmd = "kill $(ps -fu $USER | grep 'gpg-agen[t]' | awk '{print $2}')"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
