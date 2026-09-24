# Lab 2 -- standalone verification of the lwi instruction with Icarus Verilog.
# Vivado is still needed for the template's own simulation and the bitstream.
#
#   make test      manual's two test programs, both memory models, CPI per instruction
#   make blur      both image-blur programs, output checked against a reference
#   make scaling   blur at 8x8 .. 64x64, to see how the cycle ratio scales
#   make clean

SIM   := sim
BUILD := $(SIM)/build
IV    := iverilog -g2012
CORE  := picorv32.v

PROGS := baseline modified blur_baseline blur_modified
MEMS  := $(PROGS:%=$(SIM)/%.mem)

.PHONY: test blur scaling clean

$(SIM)/%.mem: $(SIM)/%.s $(SIM)/asm.py
	cd $(SIM) && python3 asm.py $*.s $*.mem

$(SIM)/test_data.mem:
	python3 -c "d=[0]*32; d[0x50//4]=20; d[0x54//4]=24; open('$@','w').write(''.join(f'{w:08x}\n' for w in d))"

$(BUILD)/slow.vvp: $(SIM)/tb.v $(CORE)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $^

$(BUILD)/fast.vvp: $(SIM)/tb.v $(CORE)
	@mkdir -p $(BUILD)
	$(IV) -DFAST_MEM -o $@ $^

test: $(MEMS) $(SIM)/test_data.mem $(BUILD)/slow.vvp $(BUILD)/fast.vvp
	@for mem in fast slow; do for p in baseline modified; do \
	  echo; echo "=== $$p, $$mem memory ==="; \
	  vvp -n $(BUILD)/$$mem.vvp +code=$(SIM)/$$p.mem +data=$(SIM)/test_data.mem +maxcycles=60 > $(BUILD)/$$p.$$mem.out; \
	  python3 $(SIM)/cpi.py $(SIM)/$$p.lst $(BUILD)/$$p.$$mem.out | grep -v "^STOP"; \
	done; done

blur: $(MEMS) $(BUILD)/slow.vvp $(BUILD)/fast.vvp
	@cd $(SIM) && python3 blur_image.py make build/blur_32.mem 32
	@for mem in fast slow; do for p in blur_baseline blur_modified; do \
	  stop=$$(awk '$$3=="nop" {print $$1; exit}' $(SIM)/$$p.lst); \
	  vvp -n $(BUILD)/$$mem.vvp +code=$(SIM)/$$p.mem +data=$(BUILD)/blur_32.mem +maxcycles=3000000 \
	      +stoppc=$$stop +dump=$(BUILD)/$$p.$$mem.dump > /dev/null; \
	  echo; echo "=== $$p, $$mem memory ==="; \
	  cd $(SIM) && python3 blur_image.py check build/$$p.$$mem.dump 32; cd ..; \
	done; done

scaling: $(MEMS) $(BUILD)/fast.vvp
	@printf "%7s %10s %10s %8s %7s\n" size baseline modified saved ratio; \
	for n in 8 16 32 64; do \
	  (cd $(SIM) && python3 blur_image.py make build/blur_$$n.mem $$n); \
	  b=0; m=0; \
	  for p in blur_baseline blur_modified; do \
	    stop=$$(awk '$$3=="nop" {print $$1; exit}' $(SIM)/$$p.lst); \
	    vvp -n $(BUILD)/fast.vvp +code=$(SIM)/$$p.mem +data=$(BUILD)/blur_$$n.mem +maxcycles=3000000 \
	        +stoppc=$$stop +dump=$(BUILD)/$$p.$$n.dump > /dev/null; \
	    c=$$(cd $(SIM) && python3 blur_image.py check build/$$p.$$n.dump $$n | sed -n 's/.*(rdcycle): //p'); \
	    if [ $$p = blur_baseline ]; then b=$$c; else m=$$c; fi; \
	  done; \
	  printf "%7s %10s %10s %8s %7.4f\n" "$${n}x$$n" $$b $$m $$((b-m)) $$(echo "$$b/$$m" | bc -l); \
	done

clean:
	rm -rf $(BUILD) $(SIM)/*.mem $(SIM)/*.lst
