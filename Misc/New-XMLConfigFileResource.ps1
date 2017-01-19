$ConfigPath = New-xDscResourceProperty -Name ConfigPath -Type String -Attribute Key -Description 'Path to config file'
$XPath = New-xDscResourceProperty -Name XPath -Type String -Attribute Key -Description 'XPath to use'
$Name = New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description 'Name of the attribute/element'
$Value = New-xDscResourceProperty -Name Value -Type String -Attribute Write -Description 'Name of the attribute/element'
$isAttribute = New-xDscResourceProperty -Name isAttribute -Type Boolean -Attribute Write -Description 'Name is an attribute'
$isElementTextValue = New-xDscResourceProperty -Name isElementTextValue -Type Boolean -Attribute Write -Description 'Name is element only'
$Attribute1 = New-xDscResourceProperty -Name Attribute1 -Type String -Attribute Write -Description 'Required for key/value pair. Default: key'
$Attribute2 = New-xDscResourceProperty -Name Attribute2 -Type String -Attribute Write -Description 'Required for key/value pair. Default: value'
$DoBackup = New-xDscResourceProperty -Name DoBackup -Type Boolean -Attribute Write -Description 'Whether to create a backup before changing a file'
$Ensure = New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -Description 'Should this resource be present or absent' -ValidateSet 'Present','Absent'
$XMLNS = New-xDscResourceProperty -Name XMLNS -Type String -Attribute Write -Description 'Define XmlNamespaceManager. If omitted the resource determines one from file.'
$NSPrefix = New-xDscResourceProperty -Name NSPrefix -Type String -Attribute Write -Description 'The prefix of the XmlNamespaceManager, which is used in the XPath'

$Parameters = @{
	Name = 'xXMLConfigFile'
	Property = @($ConfigPath,$XPath,$Name,$Value,$isAttribute,$isElementTextValue,$Attribute1,$Attribute2,$XMLNS,$NSPrefix,$DoBackup,$Ensure)
	Path = '.'
	ModuleName = 'xXMLConfigFile'
	FriendlyName = 'XMLConfigFile'
	Force = $true
}

New-xDscResource @Parameters -Verbose