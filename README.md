# xXMLConfigFile
This DSC module allows you to modify XML attributes in XML based application configuration files
## Resources
### xXMLConfigFile

* **ConfigPath:** Path to the configuration file.
* **XPath:** XPath to find the node in the XML
* **Name:** Name of the attribute or element node.
* **Value:** Value for the attribute
* **isAttribute:** Switch to distinct between a single attribute and an element with multiple attributes
* **isElementTextValue:** Switch for elements with a text node
* **Attribute1:** Name of the first attribute in a key/value pair. Default is **key**.
* **Attribute2:** Name of the second attribute in a key/value pair. Default is **value**.
* **XMLNS:** Value of the XmlNamespaceManager (e.g.: "http://schemas.microsoft.com/developer/msbuild/2003"). If omitted the resource is using the first one.
* **NSPrefix:** The prefix for the XmlNamespaceManager, which is then used in XPath.
* **DoBackup:** If set to true a backup file will be created before modifying and saving the original file.
* **Ensure:** Define whether the attribute is Present or Absent.
* **EnforceNullXMLNS:** Enforcement of not using the default XmlNamespaceManager. Usefull when items don't have one.

## Versions
### Unreleased
### 2.0.0.3
* changed parameter Name to key and allowe empty string in order to support same combinations for XPath and ConfigPath

### 2.0.0.2
* Fixed enforcement of XmlNamespaceManager
* introduced new parameter EnforceNullXMLNS

### 2.0.0.1
* Fixed Remove-XMLItem backup functionality
* improved Known Issue with multiple attributes in an element

### 2.0.0.0
* added support for Add/Remove/Modify elemnts with textvalue
* improve backup of files
* improve code

### 1.2.0.0
* added XmlNamespaceManager support

### 1.1.0.0
* fixed backup issues

### 1.0.0.0
* initial release

## Examples
### AddRemoveModifyAttributeNode
Add, remove or set an element with 2 attributes in the **//appSettings** section. The example code add an element named **add** with 2 attributes **'key=SmtpSendLogFlushInterval'** and **'value=0:00:30'** to the file and enforces that the node with the attribute **'key=SmtpRecvLogFlushInterval'** doesn't exists.
### AddRemovModifyeSingleAttributeValue
Add or remove an attribute in the **/MRSConfiguration** section. The example code shows how to ensure that the attribute 'FoolMe' doesn't exist and 2 attributes (MaxRetries/MaxActiveMovesPerSourceMDB) are present and have specified values.

## Known issues
The module uses XPath in order to find attributes and nodes in a given file. XPath is by default **case-sensitive**!
The module supports the following operations:
### 
* **single attribute:** add/remove/modify
* **elements with text node:** add/remove/modify
* **multiple attributes in an element:** you can add an element with multiple attributes only, if an element with the same neame already exists. Example: In **//appSettings** section there are several elements named **add** with 2 attributes (key/value pairs). You can add additional elements with the name 'add key=... value=...', ~~but not with a different name like 'remove key=... value=...'. In this case you first need to create an empty element and add the attributes.~~ if an element doesn't exist, the last part of the XPath after a / will be deleted and an element will be added one level up.

