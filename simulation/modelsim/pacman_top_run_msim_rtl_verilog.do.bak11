transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/bryan/Documents/school/ucla/ieee\ dav\ 2023/pacman {C:/Users/bryan/Documents/school/ucla/ieee dav 2023/pacman/game_tb.sv}
vlog -sv -work work +incdir+C:/Users/bryan/Documents/school/ucla/ieee\ dav\ 2023/pacman {C:/Users/bryan/Documents/school/ucla/ieee dav 2023/pacman/game_ghost.sv}
vlog -sv -work work +incdir+C:/Users/bryan/Documents/school/ucla/ieee\ dav\ 2023/pacman {C:/Users/bryan/Documents/school/ucla/ieee dav 2023/pacman/maze.sv}

