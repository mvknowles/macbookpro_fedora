# NOTE!!!!!
# The position of these kickstarts _matters_. imagecreator
# parses each kickstart file into a python object, which
# then gets placed in a python list. Therefore the order is
# significant. In particular, the "part" directive is specified
# in the included files. Each time "part" is read, it overwrites
# the livecd loop size. See imagecreator.kickstart.get_image_size
# code to see what happens. 
# This isn't entirely obvious from the docs (i.e. what directive
# gets precendence)
