# Lab 2 -- verification of the lwi instruction with Icarus Verilog, using the
# template's own core. Vivado is still needed for the bitstream.
#
#   make test      the manual's two test programs, cycles per instruction
#   make blur      both image-blur programs on a test image, checked pixel by pixel
#   make board     the exact programs and image the board runs, checked the way
#                  the ARM checks them (from the template's Vitis archive)
#   make scaling   blur at 8x8 .. 64x64, to see how the cycle ratio scales
#   make clean
#
# Default memory timing copies the template's testbench.v; each target also
# shows zero-wait memory where that helps explain the numbers.

SIM   := sim
BUILD := $(SIM)/build
IV    := iverilog -g2012
CORE  := pico32_final/pico32.srcs/sources_1/bd/picorv32.v
VITIS := pico32_final/vitis_export_archive.ide.zip

PROGS := baseline modified blur_baseline blur_modified
MEMS  := $(PROGS:%=$(SIM)/%.mem)
STOP   = $$(awk '$$3=="nop" {print $$1; exit}' $(SIM)/$$p.lst)

.PHONY: test blur board scaling clean

$(SIM)/%.mem: $(SIM)/%.s $(SIM)/asm.py
	cd $(SIM) && python3 asm.py $*.s $*.mem

# the two words the manual's small programs read, at 0x4000_0050 / _0054,
# same values as the template's testbench.v
$(BUILD)/test_idata.mem:
	@mkdir -p $(BUILD)
	printf '@14\n00000014\n00000018\n' > $@

$(BUILD)/ta.vvp: $(SIM)/tb.v $(CORE)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $^

$(BUILD)/fast.vvp: $(SIM)/tb.v $(CORE)
	@mkdir -p $(BUILD)
	$(IV) -DFAST_MEM -o $@ $^

test: $(MEMS) $(BUILD)/test_idata.mem $(BUILD)/ta.vvp $(BUILD)/fast.vvp
	@for mem in ta fast; do for p in baseline modified; do \
	  echo; echo "=== $$p, $$mem memory ==="; \
	  vvp -n $(BUILD)/$$mem.vvp +code=$(SIM)/$$p.mem +idata=$(BUILD)/test_idata.mem +maxcycles=150 > $(BUILD)/$$p.$$mem.out; \
	  python3 $(SIM)/cpi.py $(SIM)/$$p.lst $(BUILD)/$$p.$$mem.out | grep -v "^STOP"; \
	done; done

blur: $(MEMS) $(BUILD)/ta.vvp $(BUILD)/fast.vvp
	@cd $(SIM) && python3 blur_image.py make build/blur_32.mem 32
	@for mem in ta fast; do for p in blur_baseline blur_modified; do \
	  vvp -n $(BUILD)/$$mem.vvp +code=$(SIM)/$$p.mem +data=$(BUILD)/blur_32.mem +maxcycles=5000000 \
	      +stoppc=$(STOP) +dump=$(BUILD)/$$p.$$mem.dump > $(BUILD)/$$p.$$mem.out; \
	  echo; echo "=== $$p, $$mem memory ==="; grep -E "TRAP|STOP" $(BUILD)/$$p.$$mem.out; \
	  (cd $(SIM) && python3 blur_image.py check build/$$p.$$mem.dump 32); \
	done; done

board: $(MEMS) $(BUILD)/ta.vvp
	@python3 $(SIM)/board_programs.py $(VITIS) $(BUILD)
	@for p in blur_baseline blur_modified; do \
	  b=$${p#blur_}; \
	  vvp -n $(BUILD)/ta.vvp +code=$(BUILD)/board_$$b.mem +data=$(BUILD)/board_data.mem +maxcycles=5000000 \
	      +stoppc=$(STOP) +dump=$(BUILD)/board_$$b.dump > $(BUILD)/board_$$b.out; \
	  echo; echo "=== board's $$b program ==="; grep -E "TRAP|STOP" $(BUILD)/board_$$b.out; \
	  python3 $(SIM)/board_programs.py check $(BUILD)/board_$$b.dump $(BUILD); \
	done

scaling: $(MEMS) $(BUILD)/ta.vvp
	@printf "%7s %10s %10s %8s %7s\n" size baseline modified saved ratio; \
	for n in 8 16 32 64; do \
	  (cd $(SIM) && python3 blur_image.py make build/blur_$$n.mem $$n); \
	  b=0; m=0; \
	  for p in blur_baseline blur_modified; do \
	    vvp -n $(BUILD)/ta.vvp +code=$(SIM)/$$p.mem +data=$(BUILD)/blur_$$n.mem +maxcycles=9000000 \
	        +stoppc=$(STOP) +dump=$(BUILD)/$$p.$$n.dump > /dev/null; \
	    c=$$(cd $(SIM) && python3 blur_image.py check build/$$p.$$n.dump $$n | sed -n 's/.*(rdcycle): //p'); \
	    if [ $$p = blur_baseline ]; then b=$$c; else m=$$c; fi; \
	  done; \
	  printf "%7s %10s %10s %8s %7.4f\n" "$${n}x$$n" $$b $$m $$((b-m)) $$(echo "$$b/$$m" | bc -l); \
	done

clean:
	rm -rf $(BUILD) $(SIM)/*.mem $(SIM)/*.lst
