require 'mkmf'

have_library("c", "main")

create_makefile("iowa/classifier")
