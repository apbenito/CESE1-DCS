# Icarus Verilog simulation targets. macOS-side only; Vivado does synthesis.
IV     := iverilog -g2012
BUILD  := build

P1_SRCS := Async_Encoder_Decoder_template/Async_Encoder_Decoder.srcs
P1_DUT  := $(P1_SRCS)/sources_1/new/async_en_decode.v
P1_TB   := $(P1_SRCS)/sim_1/new/tb_async_en_decode.v

P2_SRCS := Debouncer/Debouncer.srcs
P2_DUT  := $(P2_SRCS)/sources_1/new/encoder.v
P2_TB   := $(P2_SRCS)/sim_1/new/tb_encoder.v

P3_SRCS := Road_Sign_template/Road_Sign_template.srcs
P3_DUT  := $(P3_SRCS)/sources_1/new/road_sign.v
P3_TB   := $(P3_SRCS)/sim_1/new/tb_road_sign.v

.PHONY: p1 p2 p3 clean

p1: $(BUILD)/p1.vvp
	@cd $(BUILD) && vvp p1.vvp
	@if [ "$(WAVE)" = "1" ]; then gtkwave $(BUILD)/async.vcd >/dev/null 2>&1 & fi

p2: $(BUILD)/p2.vvp
	@cd $(BUILD) && vvp p2.vvp
	@if [ "$(WAVE)" = "1" ]; then gtkwave $(BUILD)/encoder.vcd >/dev/null 2>&1 & fi

p3: $(BUILD)/p3.vvp
	@cd $(BUILD) && vvp p3.vvp
	@if [ "$(WAVE)" = "1" ]; then gtkwave $(BUILD)/road_sign.vcd >/dev/null 2>&1 & fi

$(BUILD)/p3.vvp: $(P3_DUT) $(P3_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P3_DUT) $(P3_TB)

$(BUILD)/p1.vvp: $(P1_DUT) $(P1_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P1_DUT) $(P1_TB)

$(BUILD)/p2.vvp: $(P2_DUT) $(P2_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P2_DUT) $(P2_TB)

clean:
	rm -rf $(BUILD)
