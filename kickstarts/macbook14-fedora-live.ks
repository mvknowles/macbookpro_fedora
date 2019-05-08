%include fedora-live-workstation.ks 

# good
part / --size 12000 --fstype ext4
rootpw --plaintext macbook
user --name mark --groups wheel --plaintext --password macbook 

# hackery
repo --name mk_kernel --baseurl http://localhost:8000/repo

%include macbook14-common-packages.ks
%include macbook14-common-post.ks

