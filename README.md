# GlobalToPandasDataframe
Embedded Python を使用して IRIS グローバル([$LB](https://docs.intersystems.com/irislatest/csp/docbookj/DocBook.UI.Page.cls?KEY=RCOS_flistbuild)) を Pandas Dataframe に変換する方法

[Embedded Python で Excel のデータを IRIS グローバルに格納する方法](https://jp.community.intersystems.com/node/516426) では pandas.DataFrame のデータを InterSystems IRIS グローバルに保存する方法をご紹介しました。  
こちらのサンプルでは、その逆の「InterSystems IRIS グローバル($LB) を pandas.DataFrame にする」方法をご紹介します。  
  

## サンプルコードについて
この Git のサンプルコードは、[InterSystems 開発者コミュニティ](https://jp.community.intersystems.com/) に公開している以下記事のサンプルコードです。  
  
[Embedded Python を使用して IRIS グローバル($LB) を Pandas Dataframe に変換する方法](https://jp.community.intersystems.com/node/518626)
  
## 含まれるファイル
* TestStoredProc1.xml　　　// スタジオインポート用クラス定義
* TestStoredProc1.cls　　　// VSCodeインポート用クラス定義
    
## セットアップ方法
動作バージョン InterSystems IRIS 2021.2以降
  
スタジオをご利用の方は、User.TestStoredProc1.xml を対象のネームスペースにインポート・コンパイルしてください。  
VSCodeをご利用の方は、IRISに接続後、対象のネームスペースにTestStoredProc1.cls を保存・コンパイルしてご利用ください。  
  
## 事前準備
テストで使用するグローバルデータ ^ISJ を作成します。
~~~
>znspace "USER"                               // 対象のネームスペースに移動
USER>do ##class(User.TestStoredProc1).init()  // サンプルデータ(^ISJ)の作成
USER>zwrite ^ISJ                              // データが作成されていることを確認
^ISJ=4
^ISJ(1)=$lb("Name","Age","Address")
^ISJ(2)=$lb("佐藤","50","東京")
^ISJ(3)=$lb("加藤","40","大阪")
^ISJ(4)=$lb("伊藤","30","京都")
~~~
  
## 実行方法
ターミナルで確認する場合は、以下のように実行します。
~~~
USER>do $system.Python.Shell()     // :p だけでもOK

Python 3.9.5 (default, Apr 15 2022, 01:28:04) [MSC v.1927 64 bit (AMD64)] on win32
Type quit() or Ctrl-D to exit this shell.
>>> mysql="select * from SQLUSER.TestStoredProc1_G('^ISJ')"
>>> resultset = iris.sql.exec(mysql)
>>> dataframe = resultset.dataframe()
>>> print (dataframe)
      node     value1 value2   value3
0  ^ISJ(1)     Name    Age     Address
1  ^ISJ(2)     佐藤     50       東京
2  ^ISJ(3)     加藤     40       大阪
3  ^ISJ(4)     伊藤     30       京都
>>>
>>>
>>>
~~~
