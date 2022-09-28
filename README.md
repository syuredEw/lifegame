# lifegame
FPGA上にlifegameを実装しました．対象ボードはDigilent社のZYBOです．開発環境はVivado.
使用言語はSystemVerilogです．

# 各モジュールの説明

### pckgen.sv
  VGA出力用の周波数25.125MHzの生成します．
  
### tp_lifegame.sv
 トップモジュールです．xdcファイルに制約ファイルがあります．
 
### lfsr.sv
　LFSRを用いた乱数を生成しています．
 
### vga_count_hv.sv
  VGA出力するための縦，横方向をカウントしています．
  
### rd_ram_data.sv
  ここがメインです．最初にlfsrでHighかLowを取得します．その際に1列ごとにBRAMでデータを書き込みます．
  計算判定を `lifegame_cal.sv` で行い．その結果をdinaに書き込みます．BRAMは交互に書き込み，読み込みを行います．
  counterを用いることにより判定のタイミングをゆっくりに設定しています．
  
### outputvga.sv
  ここはVGA出力のためのモジュールです．
