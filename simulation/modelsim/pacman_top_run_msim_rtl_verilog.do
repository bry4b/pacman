transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/bryan/Documents/school/ucla/ieee\ dav\ 2023/pacman {C:/Users/bryan/Documents/school/ucla/ieee dav 2023/pacman/bongo_tb.sv}
vlog -sv -work work +incdir+C:/Users/bryan/Documents/school/ucla/ieee\ dav\ 2023/pacman {C:/Users/bryan/Documents/school/ucla/ieee dav 2023/pacman/controller_bongo.sv}

