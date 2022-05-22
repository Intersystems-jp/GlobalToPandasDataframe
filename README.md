# GlobalToPandasDataframe
Embedded Python を使用して IRIS グローバル($LB) を Pandas Dataframe に変換する方法

[Embedded Python で Excel のデータを IRIS グローバルに格納する方法](https://jp.community.intersystems.com/node/516426) では pandas.DataFrame のデータを InterSystems IRIS グローバルに保存する方法をご紹介しました。  
こちらのサンプルでは、その逆の「InterSystems IRIS グローバル($LB) を pandas.DataFrame にする」方法をご紹介します。 
  
以下のようなグローバルを、Embedded Python を使用して Dataframe に変換します。
~~~
USER>zw ^ISJ
^ISJ(0)="Name,Age,Address"
^ISJ(1)="佐藤,50,東京"
^ISJ(2)="加藤,40,大阪"
^ISJ(3)="伊藤,30,京都"
~~~
  
[%Library.GlobalクラスのGetクエリ](https://docs.intersystems.com/irislatest/csp/documatic/%25CSP.Documatic.cls?&LIBRARY=%25SYS&CLASSNAME=%25Library.Global#Get) を使用して取得し、iris.sql.execを使用してdataframeに格納する方法があります。  
ただし、こちらの方法はリスト形式($lb)のまま dataframe に変換します。

~~~
USER>zw ^ISJ
^ISJ=4
^ISJ(1)=$lb("Name","Age","Address")
^ISJ(2)=$lb("佐藤","50","東京")
^ISJ(3)=$lb("加藤","40","大阪")
^ISJ(4)=$lb("伊藤","30","京都")

USER>do $system.Python.Shell()

Python 3.9.5 (default, Apr 15 2022, 01:28:04) [MSC v.1927 64 bit (AMD64)] on win32
Type quit() or Ctrl-D to exit this shell.
>>> mysql = "select name,value from %library.global_get('user','^ISJ',,2,2)"
>>> resultset = iris.sql.exec(mysql)
>>> dataframe = resultset.dataframe()
>>> print (dataframe)
   name            value
0   ^ISJ              4
1 ^ISJ(1) $lb("Name","Age","Address")
2 ^ISJ(2)     $lb("佐藤","50","東京")
3 ^ISJ(3)     $lb("加藤","40","大阪")
4 ^ISJ(4)     $lb("伊藤","30","京都")
>>>
~~~

こちらの結果の value を Name, Age, Address に分けてデータフレームに保存する場合、既存の %Global.cls のクエリで行うことはできないため、別途IRIS側でリストを分解してから処理するか、Python側でリストからデータフレームに変換する必要があります。

IRIS側で処理する場合、[カスタムクラスクエリ](https://jp.community.intersystems.com/node/481186) を使用してグローバル内の$LISTの各データを返すストアドプロシージャを作成し、それをSQL経由でアクセスする方法が考えられます。  
カスタムクエリを使用する方法は、弊社FAQサイト([既存のグローバルデータをオブジェクトやSQLインタフェースから利用する方法はありますか？](https://faq.intersystems.co.jp/csp/faq/result.csp?DocNo=50))でもご紹介しています。
  
上記FAQで紹介しているサンプルクラスを使用して、^ISJ のリストを要素別に抽出するサンプルを作成してみました。  
^ISJのValueの結果列が＄LB形式で3つなので、サンプルを以下のように変更します。
  
★GFetchクラスメソッド
~~~
 //Set Row=$LB($na(@glvn@(x)),@glvn@(x))
 Set Row=$LB($na(@glvn@(x)),$LIST(@glvn@(x),1),$LIST(@glvn@(x),2),$LIST(@glvn@(x),3))
~~~
★Gクエリ
~~~
// Query G(glvn As %String) As %Query(CONTAINID = 0, ROWSPEC = "Node:%String, Value:%String") [ SqlProc ]
Query G(glvn As %String) As %Query(CONTAINID = 0, ROWSPEC = "Node:%String, Value1:%String, Value2:%String, Value3:%String") [ SqlProc ]
~~~
  
実行例は以下のようになります。
~~~
USER>do $system.Python.Shell()

Python 3.9.5 (default, Apr 15 2022, 01:28:04) [MSC v.1927 64 bit (AMD64)] on win32
Type quit() or Ctrl-D to exit this shell.
>>> mysql="select * from SQLUSER.TestStoredProc1_G('^ISJ')"
>>> resultset = iris.sql.exec(mysql)
>>> dataframe = resultset.dataframe()
>>> print (dataframe)
     node value1 value2  value3
0 ^ISJ(1)  Name   Age Address
1 ^ISJ(2)    佐藤    50      東京
2 ^ISJ(3)    加藤    40      大阪
3 ^ISJ(4)    伊藤    30      京都
>>>
~~~
 
***
**※※※以下、GitHub用**
***
  

**手順**
***
1. スタジオをご利用の方は、User.TestStoredProc1.xml をスタジオ・管理ポータルから対象のネームスペースにインポートしてください。  
   VSCodeをご利用の方は、IRISに接続後、対象のネームスペースにTestStoredProc1.cls を保存してご利用ください。  
2. テストで使用するグローバルデータ ^ISJ を作成します。
~~~
>znspace "USER"                               // 対象のネームスペースに移動
USER>do ##class(User.TestStoredProc1).init()  // サンプルデータ(^ISJ)の作成
USER>zw ^ISJ                                  // データが作成されていることを確認
^ISJ(1)=$lb("Name","Age","Address")
^ISJ(2)=$lb("佐藤","50","東京")
^ISJ(3)=$lb("加藤","40","大阪")
^ISJ(4)=$lb("伊藤","30","京都")
~~~
  

**確認方法**
***
ターミナルで確認する場合は、以下のように実行します。
~~~
USER>do $system.Python.Shell()

Python 3.9.5 (default, Apr 15 2022, 01:28:04) [MSC v.1927 64 bit (AMD64)] on win32
Type quit() or Ctrl-D to exit this shell.
>>> mysql="select * from SQLUSER.TestStoredProc1_G('^ISJ')"
>>> resultset = iris.sql.exec(mysql)
>>> dataframe = resultset.dataframe()
>>> print (dataframe)
     node value1 value2  value3
0 ^ISJ(1)  Name   Age Address
1 ^ISJ(2)    佐藤    50      東京
2 ^ISJ(3)    加藤    40      大阪
3 ^ISJ(4)    伊藤    30      京都
>>>
~~~
