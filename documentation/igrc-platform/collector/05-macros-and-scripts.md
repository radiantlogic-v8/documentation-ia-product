---
title: Macros and scripts
description: Macros and scripts
---

# Macros and Scripts

## JavaScript syntax

The APIs described in this chapter can be used in both macros in JavaScript.

A macro is a JavaScript expression inserted into a component property field. For example, the CSV source component asks for the name of a CSV file to be processed. An absolute path may be entered in this field. However, it is possible to insert a JavaScript expression to make the constitution of the file path dynamic. The expression must be enclosed in brackets to be identified as such by the collector engine when running. Everything between these brackets is executed and the result replaces the JavaScript expression as shown in the following example:  

```javascript
{config.my_directory}\rh.csv
```

In the example above, the `my_directory` configuration variable contains `C:\Users\Paul`. At runtime, the collector engine replaces the expression in brackets with the result, which gives the following path: `C:\Users\Paul\rh.csv`

A JavaScript script is a file with the extension `.javascript`. This file is associated with the collector line and may contain all the functions called by components, for example, from a source script, a filter script, or a transition, to make its transfer conditional.  

The major difference in syntax between a macro and a JavaScript script is that the macro can only contain an expression, not an entire script. This means that all the keywords such as `for,while, if` ... are forbidden in macros.

JavaScript syntax is not described in this document because it is standard, since the product uses the Mozilla Foundation's Rhino scripting engine. Note that ternary expressions may be used in macros and in JavaScript. The syntax is:  

```javascript
condition ? expression_if_true: expression_if_false
```

The following example shows how to test if `my_directory` variable is not empty. If the variable is empty, it is replaced by a default path in Windows. Ternary expressions are very useful in macros as they allow you to test without the if keyword, which is forbidden:  

```javascript
{config.my_directory.length != 0 ? config.my_directory : "C:\Windows\Temp\rh.csv"}
```

Ternary expressions may be nested. It is therefore important to use parentheses to clearly delimit each part and avoid any ambiguity during runtime.

## Config variable

The `config` variable is available when running the collector line, and contains all the configuration values of the line and of the project configuration. All the configuration settings are present in the `config` object and accessible as properties. Values are always `String` types.  

These settings affect the behavior of the collector line. They allow us to avoid the presence of hard-coded values such as file names in the collector line settings. For example, for a CSV source, the `CSVfile` field may be filled with a macro instead of hard-coding `C:\data.csv`, as shown in the following example: `{config.csvfile}`  

The `csvfile` setting is declared in the collector line with `C:\data.csv` as its value.  

A configuration setting may be declared at the project level or at the collector line level. If a setting with the same name is declared on both levels, the collector level setting is used. This allows you to set a default value at the project level and override it in a collector line.  

The `config` variable is also present in scripting: `print(config.csvfile);`

There are two properties automatically filled in in the `config` variable:

- `projectPath`: is the absolute path of the project.
- `databaseName`: is the name of the database configuration.

## Dataset variables

A dataset is a collector of attributes, where each attribute may contain multiple values. The dataset is the element which is passed between the components of a collector line. It may be altered or completed by each component.  

When a collector line runs, the `dataset` variable is implicitly declared and contains the current dataset. It is thus possible to reach the content of the dataset within a component (for example, in the modifying component in the form of a macro) or in JavaScript.  

A collector line has a data pattern. The pattern lists all the attribute names declared in each component and their characteristics (type of attribute and multivalued indicator). The pattern helps to offer completion of the attributes in the collector line editor. It is also used when the collector line runs to performing implicit operations of data conversion. For example, when an attribute is declared by a source component as `date` type, it can be upgraded or modified by another component by passing a string. The collector engine converts the value according to the declaration in the pattern.  

The pattern is shown in the collector line editor in the Properties view when no component is selected.  

You cannot bypass the pattern while the line collector is running. An attribute can only receive values of the type declared in the pattern (after implicit conversion if needed). On the other hand, it is quite possible at runtime to dynamically add new attributes whose characteristics you specify (type of attribute and multivalued indicator) in the constructor of the `Attribute` class.

> [!warning] Having declared an attribute in the pattern (for example, in a source type component) does not add the attribute in the dataset at runtime. The attribute is only present if it is added by component or a script. The standard behavior of the source type components (for example, CSV) is to create the attribute in the dataset only if a value is present in the file. In the case of a CSV file, if the `uniqueID` column is empty for some records, the dataset will not contain the `uniqueID` attribute for records that have no value in this column. When trying to read an attribute not present in the dataset, `null` is returned. Therefore, we have to test this value before manipulating the data, as shown in the following code:
> 
> ```javascript
> var attr = dataset.get("unique_ID");

> if (attr != null) {
>   print(attr);
> }
> ```

This test should also be done in macros, for example, in the modifying component. The following code is a macro component set in the modifying component in order to capitalize the `unique_ID`. Since the unique ID may be absent, you must use a ternary expression to process the case of a `null` attribute:  

```javascript
{dataset.unique_ID != null ? dataset.unique_ID.get().toUpperCase(): ''}
```  

This macro tests whether the attribute exists in the dataset. If it does, it returns the contents of the unique ID, capitalized. Otherwise, it returns an empty string.  

Let's take the example of an attribute called `myAttribute`, declared in a modifying component and valuated by a script. The following code allows us to add the attribute to the dataset with a value:

```javascript
var attr = new Attribute("myAttribute");

attr.set("Paul");
dataset.add(attr);
```

In the example above, the first line creates an attribute without specifying the type of data or the multivalued indicator, because with the name of the attribute, the collector engine finds this information in the pattern.  

In the case of an attribute missing from the pattern, you must specify all the information as shown in the following example. The pattern is then completed dynamically with a new attribute.  

```javascript
var attr = new Attribute("myAttribute", "String", false);

attr.set("Paul");
dataset.add(attr);
```

In the example above, the first line creates an attribute that does not exist in the pattern. The attribute is declared as being a `String` type and single-valued (multivalued parameter set to `false`).  

A dataset also contains a list of events. These events contribute to the identification of rejects or records with an anomaly. These events can be used in transitions between components to create conditional forking. Writing a JavaScript function is necessary to test for the presence of an event and to allow the transition to the next component or not. The following code shows a function that prevents it from moving to the next component if the `empty_unique_ID` event is detected:  

```javascript
function testUniqueID() {
  return ! dataset.hasEvent("empty unique ID");
}
```

The `testUniqueID` function is configured in the transaction. When the dataset contains an `empty_unique_ID` event, the JavaScript function returns `false` which prohibits from moving on to the next component.  

It is important to note that the events present in the dataset have a very limited lifespan because they are deleted upon entering each component to avoid their accumulation while running through the dataset of the whole collector line.

## Dataset class API

The DataSet class contains the APIs to manipulate both the dataset (the attributes) and the events. It provides access to the attributes in the form of methods and properties.

### Properties corresponding to the pattern

All the attributes of the dataset are available in the form of properties. This allows syntax like `dataset.attribute` as shown in the following example for the `first_name` attribute: `var attr =dataset.first_name;`

Note that the returned value is an `Attribute` type object, not the value of the attribute. So to retrieve the first name, you must use the `get` method like this:

```javascript
var attr = dataset.first_name;

if (attr != null) {
  print(attr.get());

```

> [!warning] If the attribute does not exist in the dataset, the value returned is `null`. It is therefore necessary to test whether the returned value is a valid attribute (not null) before using the `get` method.

Properties are read- and write-accessible. In write mode, the attribute is replaced by the new attribute. If the attribute does not exist in the dataset, it is added. The following example shows how to add a new single-valued `String` type attribute to the data set:  

```javascript
var attr = new Attribute("myAttribute", "String", false);

attr.set("Paul");
dataset.myAttribute = attr;
```

The first line creates a new attribute called _myAttribute_ but which is not yet added to the dataset. The second line sets the value of the attribute. The third line adds the attribute to the dataset. Note that the attribute name is repeated in the third line. This syntax allows you to replace or add an attribute regardless of whether the dataset contained an attribute with the same name or not.  

Syntax using the `dataset` APIs allows you to obtain the same result, as shown in the following code:  

```javascript
var attr = new Attribute("myAttribute", "String", false);

attr.set("Paul");
dataset.remove("myAttribute");
dataset.add(attr);
```

The `add` method of the `dataset` object adds an attribute to the dataset only if it does not already exist. You must therefore remove the attribute with the `remove` method before adding it to process a replacement.  

It is also possible to add or replace an attribute by just providing a value, like this: `dataset.myAttribute = "Paul";`

Note that this is only a shortcut. In reality, the value is not added directly to the dataset. An attribute is created with the name `myAttribute`, then the value is stored in the attribute, then the attribute is added to the dataset.

### Length property

The length property returns the number of attributes present in the dataset. An attribute can be empty or contain one or more values.  

This property may be used to list the attributes of the dataset using a for loop as in the following example:  

```javascript
for (var i = 0; i < dataset.length; i++) {
  var attr = dataset.get(i);
  print(attr);
}
```

An easier way to list the attributes of the dataset is to use another variant of the for loop like this:  

```javascript
for (var attr in dataset) {
  print(attr);
}
```

### Add method

Adds an attribute in the dataset. The dataset does not accept duplicate attribute names. If an attribute with the same name already exists, the operation fails. To replace an attribute with the same name, you must first delete the data set with the `remove` method. The `add` method accepts either an `Attribute` type object or an attribute name. In the case of a call with an attribute name, the attribute will be created with the type declared in the pattern. If the pattern does not know the name, the created attribute is a `String` type, and single-valued. To change these characteristics, it is possible to pass two additional parameters.  

**Signature**:  

- `add(name_or_attribute, [type], [multivalued])`: Attribute

**Return value**:  

- The attribute added or null if the add failed

**Parameters**:  

- `name_or_attribute`: `Attribute` or `String`. Name of the attribute or `Attribute` type object. If this parameter is a string, two additional parameters can specify the type and whether the attribute is multivalued.
- `type`: `String` (optional) Attribute type (`String, Boolean, Number` or `Date`). Ignored if the parameter `name_or_attribute` is an `Attribute` type.
- `multivalued: Boolean` (optional). Indicates whether the attribute to be created should be multivalued. Ignored if the parameter `name_or_attribute` is an `Attribute` type.  

**Example call**:

```javascript
var attr = new Attribute("myAttribute", "String", false);

attr.set("Paul");
dataset.add(attr);
```

### Duplicate method

Duplicates an attribute present in the dataset under a new name.
The new name must be unique. The set of values is duplicated so that the two do not share any attribute value. Note that both attributes are now considered different by the equals method because of their name.  

**Signature**:  

- `duplicate(oldName, newName)`: Attribute

**Return value**:  

- The duplicated attribute or null if the duplication failed

**Parameters**:  

- `oldName`: `String`. Name of attribute to be duplicated.
- `newName`: `String`. New name of duplicated attribute.

**Example call**:  

```javascript
var newAttr = dataset.duplicate("old", "new");

if (newAttr == null) {
  print("Error: the dataset does not contain the attribute 'old' or
  it already contains an attribute 'new'");
}
```

### Equals method

Checks equality with another object. A dataset is considered equal to another if the two datasets have the same attributes (characteristics and list of values)  

**Signature**:  

- `equals(object)`: `Boolean`  

**Return value**:  

- `true` if the object passed as a parameter is a dataset with the same attributes

**Parameters**:  

- `object`: `Object`. The object to compare with the dataset.

**Example call**:

```javascript
var same = dataset.equals(otherDataset);

if (! same) {
  print("The two datasets are different");
}
```

### Get method

Retrieves an attribute by its name.  

**Signature**:  

- `get(name)`: `Attribute`  

**Return value**:  

- The attribute or null if no attribute corresponds to the name sent as a parameter

**Parameters**:  

- `name`: `String`. Name of the attribute sought.

**Example call**:  

```javascript
var attr = dataset.get("myAttribute");

if (attr == null) {
  print("The attribute 'myAttribute' does not exist in the dataset");
}
```

### Remove method

Deletes an attribute from the dataset by its name.  

**Signature**:  

- `remove(name)`: `Attribute`

**Return value**:  

- The deleted attribute, or null if the deletion failed

**Parameters**:  

- `name`: `String`. Name of the attribute to delete.

**Example call**:  

```javascript
var attr = dataset.remove("myAttribute");

if (attr == null) {
  print("The attribute 'myAttribute' does not exist in the dataset");
}
```

### Rename method

Renames an attribute. The new name must be unique.  

**Signature**:  

- `rename(oldName, newName)`: Attribute

**Return value**:  

- The renamed attribute or `null` if the renaming failed

**Parameters**:  

- `oldName`: String Name of the attribute to rename.
- `newName`: String New attribute name.

**Example call**:  

```javascript
var attr = dataset.rename("old", "new");

if (attr == null) {
  print("Error: the dataset does not contain the attribute 'old' or
  it already contains an attribute 'new'");
}
```

### IsEmpty method

Verifies if the attribute contains a non-empty value  

**Signature**:  

- `isEmpty(name_or_attribute)`: `Boolean`

**Return value**:  

- `true` if the attribute contains at least non-empty value

**Parameters**:  

- `name_or_attribute`: `String` or `Attribute`. Name of the attribute or Attribute type object.

**Example call**:  

```javascript
var vide = dataset.isEmpty("myAttribute");

if (vide) {
  print("The attribute 'myAttribute' of the dataset is empty");
}
```

### Clear events

Erases all the events detected  

**Signature**:

- `clearEvents(): Void`

**Return value**:  

- none

**Parameters**:

- none

**Example call**:  

`dataset.clearEvents();`

### Add event

Add an event to the list  

**Signature**:  

- `addEvent(name)`: `Void`

**Return value**:  

- none

**Parameters**:  

- name: String Name of the event to add.

**Example call**:  

`dataset.addEvent("no unique ID");`

### Remove event

Deletes an event from the list.  

**Signature**:  

- `removeEvent(name)`: `Void`  

**Return value**:  

- none  

**Parameters**:  

- `name`: `String`. Name of the event to delete.  

**Example call**:  

`dataset.removeEvent("no unique ID");`

### Has event

Verifies the presence of an event in the list  

**Signature**:  

- `hasEvent(name)`: `Boolean`  

**Return value**:  

- true if the event is present in the list  

**Parameters**:  

- name: String Name of the event to verify.  

**Example call**:  

```javascript
var EmptyUniqueID = dataset.hasEvent("no unique ID");

if (EmptyUniqueID) {
  print("Error: Identity has no unique ID");
}
```

### Event count

Retrieves the number of events present in the list.  

**Signature**:  

- `eventCount()`: `Number`  

**Return value**:  

- The number of events in the list  

**Parameters**:  

- none  

**Example call**:  

 ```javascript
 var nb = dataset.eventCount();

 if (nb == 0) {
   print("No event detected");
 }
 ```

### ToString

Constructs a string giving the content of the dataset.  

**Signature** :  

- `toString()`: `String`  

**Return value** :  

- String containing the list of attribute names separated by commas  

**Parameters** :  

- none  

**Example call**:  

```javascript
print``("Content of dataset: " +` `dataset``.toString());
```

### GetEvents method

Retrieves the list of events.  

**Signature**:  

- `getEvents()`: `Array`  

**Return value**:  

- A table containing the events  

**Parameters**:  

- none  

**Example call**:  

```javascript
var events = dataset.getEvents();

if (events != null) {
    for (var event in events) {
    print("Event " + event + " detected");
    }
}
```
