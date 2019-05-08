#!/usr/bin/python3

import os
import os.path
import sys

import imgcreate
from imgcreate.errors import KickstartError

def main():
        name = imgcreate.build_name(options.kscfg, options.image_type + "-")
        fslabel = imgcreate.build_name(options.kscfg,
                                        options.image_type + "-",
                                        maxlen = imgcreate.FSLABEL_MAXLEN,
                                        suffix = "%s-%s" %(os.uname()[4], time.strftime("%Y%m%d%H%M")))

    try:
            creator = imgcreate.LiveImageCreator(ks, name,
                                            fslabel=fslabel,
                                            releasever=options.releasever,
                                            tmpdir=os.path.abspath(options.tmpdir),
                                            useplugins=options.plugins,
                                            title=title, product=product,
                                            cacheonly=options.cacheonly,
                                            docleanup=not options.nocleanup)
    except imgcreate.CreatorError as e:
        logging.error(u"%s creation failed: %s", options.image_type, e)
        return 1

    creator.compress_type = options.compress_type
    creator.skip_compression = options.skip_compression
    creator.skip_minimize = options.skip_minimize
    if options.cachedir:
        options.cachedir = os.path.abspath(options.cachedir)

    try:
        creator.mount(options.base_on, options.cachedir)
        creator.install()
        if (options.flat_squashfs and
          'rd.live.overlay.overlayfs' not in ks.handler.bootloader.appendLine):
            ks.handler.bootloader.appendLine += 'rd.live.overlay.overlayfs'
        creator.configure()
        if options.give_shell:
            print("Launching shell. Exit to continue.")
            print("----------------------------------")
            creator.launch_shell()
        creator.unmount()
        ops = []
        if 'rd.live.overlay.overlayfs' in ks.handler.bootloader.appendLine:
            ops += ['flatten-squashfs']
        creator.package(ops=ops)
    except (imgcreate.CreatorError, DnfBaseError) as e:
        logging.error(u"Error creating Live CD : %s" % e)
        return 1
    finally:
        creator.cleanup()

    return 0

def do_nss_sss_hack():
    import ctypes as forgettable
    hack = forgettable._dlopen('libnss_sss.so.2')
    del forgettable
    return hack

if __name__ == "__main__":
    hack = do_nss_sss_hack()
    sys.exit(main())
