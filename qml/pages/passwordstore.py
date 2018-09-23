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

import os
import pyotherside
from subprocess import Popen, PIPE

PSDIR = os.path.join(os.path.expanduser('~'), '.password-store')


def _does_match(candidate, inputs, *, idx=0):
    """Recursively search candidate for given inputs.
    Returns if all the inputs are exhausted or something is definitely not found
    """

    # When inputs is exhausted, we have found all we need
    if len(inputs) == 0:
        return True

    input = inputs[0]  # Cannot mutate the list, as it would affect the caller as well
    idx = candidate.lower().find(input.lower())

    # Immediately abort if nothing is found...
    if idx == -1:
        return False

    # ... or look at the next part of the candidate ...
    candidate = candidate[(idx + 1):]

    # ... with the remaining inputs
    return _does_match(candidate, inputs[1:], idx=idx)


class passwordstore():
    def search(*args):
        text = args[0]
        ps_dir = '{}/'.format(PSDIR)
        inputs = text.split()
        output = []

        # find all files matching input and end with .gpg
        cmd = "find " + PSDIR + " -iname '*.gpg'"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        # replace some strings (homedir, .gpg)
        out_replace = out.decode('utf-8').replace(ps_dir, '').replace('.gpg', '')
        # split result on newlines to get a list
        out_list = out_replace.split('\n')

        # see if we can find our searches
        output = [candidate for candidate in out_list if _does_match(candidate, inputs)]

        return sorted(output)

    def show_login(input):
        output = []
        # look at login from pass output
        cmd = "pass show " + input + " | grep '^login:'"
        print(cmd)
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('login: ', '').strip()
        output = out_replace
        return output

    def show_pass(input):
        output = []
        # show password
        cmd = "pass show " + input + " | head -1"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        # comment in for debugging, elsewise pw is in cleartext in debug log
        # pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('login: ', '').strip()
        output = out_replace
        return output

    def show_url(input):
        output = []
        # look at url from pass output
        cmd = "pass show " + input + " | grep '^url:'"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('url: ', '').strip()
        output = out_replace
        return output

    def git_pull():
        output = []
        cmd = "pass git pull"
        p = Popen(["bash", "-c", cmd], stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        pyotherside.send('stdout', out)
        pyotherside.send('stderr', err)
        # replace some strings (login: )
        out_replace = out.decode('utf-8').replace('url: ', '').strip()
        output = out_replace
        return output
