Class User.TestStoredProc1 Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Projection JavaProjection1 As %Projection.Java;

Property glvn As %String(TRUNCATE = 1);

ClassMethod init() [ Language = objectscript ]
{
	kill ^ISJ
	set ^ISJ(1)=$lb("Name","Age","Address")
	set ^ISJ(2)=$lb("佐藤","50","東京")
	set ^ISJ(3)=$lb("加藤","40","大阪")
	set ^ISJ(4)=$lb("伊藤","30","京都")
}

ClassMethod GClose(QHandle As %Binary) As %Status [ Language = objectscript ]
{
 Set QHandle=""
 Quit $$$OK
}

ClassMethod GExecute(ByRef QHandle As %Binary, glvn As %String) As %Status [ Language = objectscript ]
{
 Set QHandle=$LB("",glvn)
 Quit $$$OK
}

ClassMethod GFetch(ByRef QHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ Language = objectscript ]
{
 Set Row=""
 ; pull data out of QHandle
 Set x=$List(QHandle,1)
 Set glvn=$List(QHandle,2)
 
 ; $Order to next node
 Set x=$O(@glvn@(x))

 ; update QHandle for next fetch
 Set QHandle=$LB(x,glvn)
 ; test for end
 If x="" Set AtEnd=1 Quit $$$OK
 ; fill in Row with data for this row
 
 //Set Row=$LB($na(@glvn@(x)),@glvn@(x))
 Set Row=$LB($na(@glvn@(x)),$LIST(@glvn@(x),1),$LIST(@glvn@(x),2),$LIST(@glvn@(x),3))
 Quit $$$OK
}

ClassMethod MExecute(command As %String) As %String [ Language = objectscript ]
{
 Set %value = ""
 If $Extract(command,1)="=" {
   Set command = "Set %value "_command
 }
 Xecute command
 Set value = %value
 Kill %value
 Quit value
}

Query G(glvn As %String) As %Query(CONTAINID = 0, ROWSPEC = "Node:%String, Value1:%String, Value2:%String, Value3:%String") [ SqlProc ]
{
}

Storage Default
{
<Data name="TestStoredProc1DefaultData">
<Value name="1">
<Value>glvn</Value>
</Value>
<Value name="2">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^ooTestStoredProc1D</DataLocation>
<DefaultData>TestStoredProc1DefaultData</DefaultData>
<IdLocation>^ooTestStoredProc1D</IdLocation>
<IndexLocation>^ooTestStoredProc1I</IndexLocation>
<StreamLocation>^User.TestStoredProc1S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
