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

BN_DUT  := LFSR/lfsr.v
BN_TB   := LFSR/tb_lfsr.v

.PHONY: p1 p2 p3 bonus clean

p1: $(BUILD)/p1.vvp
	@cd $(BUILD) && vvp p1.vvp
	@if [ "$(WAVE)" = "1" ]; then echo ""; echo "waveform: $(BUILD)/async.vcd"; command -v code >/dev/null 2>&1 && code "$(BUILD)/async.vcd" || true; fi

p2: $(BUILD)/p2.vvp
	@cd $(BUILD) && vvp p2.vvp
	@if [ "$(WAVE)" = "1" ]; then echo ""; echo "waveform: $(BUILD)/encoder.vcd"; command -v code >/dev/null 2>&1 && code "$(BUILD)/encoder.vcd" || true; fi

p3: $(BUILD)/p3.vvp
	@cd $(BUILD) && vvp p3.vvp
	@if [ "$(WAVE)" = "1" ]; then echo ""; echo "waveform: $(BUILD)/road_sign.vcd"; command -v code >/dev/null 2>&1 && code "$(BUILD)/road_sign.vcd" || true; fi

$(BUILD)/p3.vvp: $(P3_DUT) $(P3_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P3_DUT) $(P3_TB)

bonus: $(BUILD)/bonus.vvp
	@cd $(BUILD) && vvp bonus.vvp
	@if [ "$(WAVE)" = "1" ]; then echo ""; echo "waveform: $(BUILD)/lfsr.vcd"; command -v code >/dev/null 2>&1 && code "$(BUILD)/lfsr.vcd" || true; fi

$(BUILD)/bonus.vvp: $(BN_DUT) $(BN_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(BN_DUT) $(BN_TB)

$(BUILD)/p1.vvp: $(P1_DUT) $(P1_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P1_DUT) $(P1_TB)

$(BUILD)/p2.vvp: $(P2_DUT) $(P2_TB)
	@mkdir -p $(BUILD)
	$(IV) -o $@ $(P2_DUT) $(P2_TB)

clean:
	rm -rf $(BUILD)
