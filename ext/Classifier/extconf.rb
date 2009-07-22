require 'mkmf'

dir_config("classifier")
have_library("c", "main")

create_makefile("classifier")
