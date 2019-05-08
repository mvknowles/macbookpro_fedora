#!/usr/bin/python3

import os
import sys
import types
import shutil
import importlib.machinery

import imgcreate

import http.server
import socketserver
import threading

DIRECTORY="/home/mark/macbookpro14_fedora/f27"
class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

class WebServer(threading.Thread):
    def run(self):
#        Handler = http.server.SimpleHTTPRequestHandler
        httpd = socketserver.TCPServer(("", 8000), Handler)
        httpd.serve_forever()


WebServer().start()
import time
time.sleep(2)

class Proxy(imgcreate.LiveImageCreator):
    def _do_bindmounts(self):
        p = self._ImageCreator__get_instroot()
        print("NIG")
        sys.stderr.write("NIG")
        print(p)
        t = os.path.join(p, "tmp")
        if os.path.exists(t) == False:
            os.makedirs(t)

        src_repo = "/home/mark/macbookpro14_fedora/f27/repo"
        r = os.path.join(t, "repo")
        if os.path.exists(r):
            shutil.rmtree(r)
        shutil.copytree(src_repo, r)
        print(dir(self))
        super(Proxy, self)._do_bindmounts()

#    def _mount_instroot(self, base_on=None):
#        #print(dir(self))
#        p = self._ImageCreator__get_instroot()
#        print(p)
#        print (os.path.exists(p))
#        print(os.listdir(p))
#        print(os.system("mount"))
#        #print(super(Proxy,self)._get_instroot())
#        sys.stderr.write("HERE MOFOS PEANUT\n")
#        sys.exit(0)

#    def __getattribute__(self, name):
#        print(name)
#        sys.stderr.write("HERE MOFOS\n")
#        return super(Proxy, self).__getattribute__(name)
#
#    def _get_outdir(self):
#        print("WE MADE IT")
#        sys.exit(0)
#        return super()._get_outdir()
    

#    def __get_outdir(self, *args, **kwargs):
#        print("WE MADE IT")
#        sys.exit(0)
#        super().__get_outdir(*args, **kwargs)

#imgcreate.LiveImageCreator = Proxy

loader = importlib.machinery.SourceFileLoader("live", "/usr/bin/livecd-creator")
mod = types.ModuleType(loader.name)
loader.exec_module(mod)

#spec = importlib.util.spec_from_file_location("live", "/usr/bin/livecdcreator")
#mod = importlib.util.module_from_spec(spec)
#spec.loader.exec_module(mod)

if __name__ == "__main__":
    sys.exit(mod.main())
