onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spuTb/dut/clk
add wave -noupdate /spuTb/dut/reset
add wave -noupdate /spuTb/dut/unit_id
add wave -noupdate /spuTb/dut/opcode_even
add wave -noupdate /spuTb/dut/opcode_odd
add wave -noupdate {/spuTb/dut/registerFile/registerFile[0]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[1]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[2]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[3]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[4]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[5]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[6]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[7]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[8]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[9]}
add wave -noupdate {/spuTb/dut/registerFile/registerFile[10]}
add wave -noupdate -radix decimal /spuTb/dut/oddPipe/ls/ls_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[160]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[161]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[162]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[163]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[164]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[165]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[166]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[167]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[168]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[169]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[170]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[171]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[172]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[173]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[174]}
add wave -noupdate -group 32'd160 -radix decimal {/spuTb/dut/oddPipe/ls/lsa_mem[175]}
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /spuTb/dut/evenPipe/opcode
add wave -noupdate /spuTb/dut/evenPipe/ra_rd_even
add wave -noupdate /spuTb/dut/evenPipe/rb_rd_even
add wave -noupdate /spuTb/dut/evenPipe/rc_rd_even
add wave -noupdate /spuTb/dut/evenPipe/rt_wt_even
add wave -noupdate /spuTb/dut/evenPipe/addr_rt_wt_even
add wave -noupdate /spuTb/dut/evenPipe/regWr_en_even
add wave -noupdate /spuTb/dut/evenPipe/imm7
add wave -noupdate /spuTb/dut/evenPipe/imm10
add wave -noupdate -expand -group {simple fixed 1 stages} -radix hexadecimal /spuTb/dut/evenPipe/fx1_stage1_result
add wave -noupdate -expand -group {simple fixed 1 stages} /spuTb/dut/evenPipe/fx1_stage2_result
add wave -noupdate -group {simple fixed 2 stages} /spuTb/dut/evenPipe/fx2_stage1_result
add wave -noupdate -group {simple fixed 2 stages} /spuTb/dut/evenPipe/fx2_stage2_result
add wave -noupdate -group {simple fixed 2 stages} /spuTb/dut/evenPipe/fx2_stage3_result
add wave -noupdate -group {byte stages} /spuTb/dut/evenPipe/byte_stage1_result
add wave -noupdate -group {byte stages} /spuTb/dut/evenPipe/byte_stage2_result
add wave -noupdate -group {byte stages} /spuTb/dut/evenPipe/byte_stage3_result
add wave -noupdate -group sp_fp_stages /spuTb/dut/evenPipe/sp_fp_stage1_result
add wave -noupdate -group sp_fp_stages /spuTb/dut/evenPipe/sp_fp_stage2_result
add wave -noupdate -group sp_fp_stages /spuTb/dut/evenPipe/sp_fp_stage3_result
add wave -noupdate -group sp_fp_stages /spuTb/dut/evenPipe/sp_fp_stage4_result
add wave -noupdate -group sp_fp_stages /spuTb/dut/evenPipe/sp_fp_stage5_result
add wave -noupdate -group sp_fp_stages /spuTb/dut/evenPipe/sp_fp_stage6_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage1_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage2_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage3_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage4_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage5_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage6_result
add wave -noupdate -group sp_int_stages /spuTb/dut/evenPipe/sp_int_stage7_result
add wave -noupdate /spuTb/dut/forwardMacro/FWE3
add wave -noupdate /spuTb/dut/forwardMacro/FWE4
add wave -noupdate /spuTb/dut/forwardMacro/FWE5
add wave -noupdate /spuTb/dut/forwardMacro/FWE6
add wave -noupdate /spuTb/dut/forwardMacro/FWE7
add wave -noupdate /spuTb/dut/forwardMacro/FWE8
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /spuTb/dut/oddPipe/unit_id
add wave -noupdate /spuTb/dut/oddPipe/opcode
add wave -noupdate /spuTb/dut/oddPipe/ra_rd_odd
add wave -noupdate /spuTb/dut/oddPipe/rb_rd_odd
add wave -noupdate /spuTb/dut/oddPipe/rc_rd_odd
add wave -noupdate /spuTb/dut/oddPipe/rt_wt_odd
add wave -noupdate /spuTb/dut/oddPipe/addr_rt_wt_odd
add wave -noupdate /spuTb/dut/oddPipe/regWr_en_odd
add wave -noupdate /spuTb/dut/oddPipe/imm7
add wave -noupdate /spuTb/dut/oddPipe/imm10
add wave -noupdate /spuTb/dut/oddPipe/imm16
add wave -noupdate -group {permute stages} /spuTb/dut/oddPipe/perm_stage1_result
add wave -noupdate -group {permute stages} /spuTb/dut/oddPipe/perm_stage2_result
add wave -noupdate -group {permute stages} /spuTb/dut/oddPipe/perm_stage3_result
add wave -noupdate -group {ls stages} /spuTb/dut/oddPipe/ls_stage1_result
add wave -noupdate -group {ls stages} /spuTb/dut/oddPipe/ls_stage2_result
add wave -noupdate -group {ls stages} /spuTb/dut/oddPipe/ls_stage3_result
add wave -noupdate -group {ls stages} /spuTb/dut/oddPipe/ls_stage4_result
add wave -noupdate -group {ls stages} /spuTb/dut/oddPipe/ls_stage5_result
add wave -noupdate -group {ls stages} /spuTb/dut/oddPipe/ls_stage6_result
add wave -noupdate /spuTb/dut/forwardMacro/FWO4
add wave -noupdate /spuTb/dut/forwardMacro/FWO5
add wave -noupdate /spuTb/dut/forwardMacro/FWO6
add wave -noupdate /spuTb/dut/forwardMacro/FWO7
add wave -noupdate /spuTb/dut/forwardMacro/FWO8
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {218 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 290
configure wave -valuecolwidth 160
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {172 ns} {302 ns}
