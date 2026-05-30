#bin/bash
export http_proxy="http://127.0.0.1:20170"
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
yay -S balena-etcher
