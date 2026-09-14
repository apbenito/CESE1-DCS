# Icarus Verilog simulation targets. macOS-side only; Vivado does synthesis.
IV     := iverilog -g2012
BUILD  := build

P1_SRCS := Async_Encoder_Decoder_template/Async_Encoder_Decoder.srcs
P1_DUT  := $(P1_SRCS)/sources_1/new/async_en_decode.v
P1_TB   := $(P1_SRCS)/sim_1/new/tb_async_en_decode.v

.PHONY: p1 clean

p1: $(BUILD)/p1.vvp
	@cd $(BUILD) && vvp p1.vvp
	@if [ "$(WAVE)" = "1" ]; then gtkwave $(BUILD)/*.vcd >/dev/null 2>&1 & fi

$(BUILD)/p1.vvp: $(P1_DUT) $(P1_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P1_DUT) $(P1_TB)

clean:
	rm -rf $(BUILD)
