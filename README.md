## 構成
- mashiro.lua : 本体
- APPsList.lua : アプリのリスト
- APPsフォルダ : アプリを入れておくフォルダ




## これは何？
RigidChips上で動くGUIシステムです。  
ウィンドウ外にはみ出した線の切り取り処理、  
ウィンドウの移動、拡大縮小、スクロールに対応。  

動かすにはRigidChipsにSpiritusが入っていることが必須です。  
その他必須ライブラリ  
cel/RC/Spell.lua		    --cel氏製フォント表示ライブラリ  
cel/font/PathData.lua	  --cel氏製フォントライブラリ  
OstLib/G2VTFtSb-Cel.lua --Ostwald氏製フォントライブラリ  


## なぜ作ったか
RigidChips上では、描画関連のコマンドが  
- 線の色を変える  
- 線の始点を指定  
- 線の終点を指定

の３つしかないため、様々な情報を画面上に描画したい際に不便である。  
そこで、WindowsライクなGUIシステムを開発することでこれらの問題の解決を図った。
