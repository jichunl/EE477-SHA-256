module vcsdumper;
// synopsys translate_off
  initial begin
    if ($test$plusargs("vpdfile")) begin
      $vcdpluson();
      $vcdplusmemon();
    end
  end

  final begin
    if ($test$plusargs("vpdfile")) begin
      $vcdplusoff();
      $vcdplusmemoff();
    end
  end
// synopsys translate_on
endmodule
