Class GS2017.Loader Extends (%Persistent, %XML.Adaptor)
{

Property Type As %String;

Property LexicalId As %Integer;

Property SourceLine As %String(MAXLEN = "");

ClassMethod LoadFile(File As %String, Type As %String) As %Integer
{
	Set stream=##class(%Stream.FileCharacter).%New()
	Set sc=stream.LinkToFile(File)
	set cnt=0
	While 'stream.AtEnd {
		Set line=stream.ReadLine()
		set lexId=$piece(line,$char(9),1)
		set lexLen=$length(lexId,"/")
		set lexId=$piece(lexId,"/",lexLen)
		set lexTitle=$piece(line,$char(9),2)
		if cnt=0 { set cnt=$increment(cnt) continue }
		&sql(insert into GS2017.Loader (Type,LexicalId,SourceLine) values (:Type,:lexId,:lexTitle))
		if SQLCODE'=0 { set ^%jks($i(^%jks))="SQLCODE="_SQLCODE_" lexTitle="_lexTitle }
		set cnt=$i(cnt)
		if (cnt#1000=0) { s ^%jks("curLoad")=cnt }
	}
	quit cnt
}

ClassMethod loadprobdefaults(File As %String) As %Integer
{
	&sql(delete from GS2017.Loader where Type='Default Problem')
	Set stream=##class(%Stream.FileCharacter).%New()
	Set sc=stream.LinkToFile(File)
	set cnt=0
	set oldLex=""
	set header=stream.ReadLine()
	While 'stream.AtEnd {
		Set line=stream.ReadLine()
		set lexId=$piece(line,",",1)
		set lexLine=$piece(line,",",2,99)
		set lexTitle=$piece(lexLine,"""",2)
		set varId=$tr($piece(lexLine,"""",3),",","")
		if (cnt'=0),(oldLex=lexTitle) { continue }
		;if cnt=0 { set cnt=$increment(cnt) continue }
		&sql(insert into GS2017.Loader (Type,LexicalId,SourceLine) values ('Default Problem',:lexId,:lexTitle))
		if SQLCODE'=0 { set ^%jks($i(^%jks))="SQLCODE="_SQLCODE_" lexTitle="_lexTitle }
		set cnt=$i(cnt)
		set oldLex=lexTitle
		;if cnt > 50 quit
		if (cnt#1000=0) { s ^%jks("curLoad")=cnt }
	}
	quit cnt
}

Index TypeIndex On Type;

Storage Default
{
<Data name="LoaderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Type</Value>
</Value>
<Value name="3">
<Value>LexicalId</Value>
</Value>
<Value name="4">
<Value>SourceLine</Value>
</Value>
</Data>
<DataLocation>^GS2017.LoaderD</DataLocation>
<DefaultData>LoaderDefaultData</DefaultData>
<IdLocation>^GS2017.LoaderD</IdLocation>
<IndexLocation>^GS2017.LoaderI</IndexLocation>
<StreamLocation>^GS2017.LoaderS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
