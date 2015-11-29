# MinecraftScript
マインクラフトサーバーの保守に使用しているスクリプトです。

#内容
1. ServerBackup.sh 
  - Worldデータをバックアップします。
2. ServerRestart.sh
  - サーバーを再起動します。その際Overviewerによるマップの生成を行うようになっています。
3. ServerUpdate.sh
  - サーバーをアップデートした際、古いデータを新しいサーバに移行するときに使います。

#使い方
Setting項目を自分の環境に合わせて書き換えるだけです。

ServerBackup.shとServerRestart.shをcronに登録しておけば自動で保守を行ってくれます。

Minecraft Wikiの[Tutorials/Server startup script](http://minecraft.gamepedia.com/Tutorials/Server_startup_script)を参考にしているので、
詳しい使い方はそちらを参照してください。
