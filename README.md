# xXMLConfigFile
This DSC module allows you to modify XML attributes in XML based application configuration files
## Resources

* **xXMLConfigFile**

## Versions
### 1.0.0.0
* initial release

## Examples
### AddRemoveModifyAttributeNode
Add, remove or set an element with 2 attributes in the **//appSettings** section. The example code 
### AddRemovModifyeSingleAttributeValue
Add or remove an attribute in the **/MRSConfiguration** section. The example code shows how to ensure that the attribute 'FoolMe' with a value of 'really' exist and the attribute 'FoolYou' doesn't.

## Known issues
The module supports the following operations:
### 
* **single attribute:** add/remove/modify
* **multiple attributes in an element:** you can add an element with multiple attributes only, if an element with the same neame already exists. Example: In **//appSettings** section there are several elements named **add** with 2 attributes (key/value pairs). You can add additional elements with the name 'add key=... value=...', but not with a different name like 'remove key=... value=...'.
