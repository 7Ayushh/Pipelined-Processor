transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/forwarding.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/insdecoder.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/hazard_logic.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/branch_pred.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/MulticycleLMSM.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/pipe_reg.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/02. main/IITB_CPU.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/sign_extend.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/ROM.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/RF.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/register_generic.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/RAM.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/pri_encoder.vhd}
vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/01. components/alu.vhd}

vcom -93 -work work {G:/My Drive/Insti Material/04. Sem 4/05. EE309/03. Project/02. Project/Project Files/IITB_CPU/03. testbench/testbench.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
