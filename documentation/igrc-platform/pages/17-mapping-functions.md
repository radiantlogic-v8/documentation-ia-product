---
title: Mapping Functions
description: Mapping Functions
---

# Mapping Functions

Mappings are small functions that allow to modify a value into another value when it meets certain conditions.  
These functions are not part of the page, they need to be declared outside of it.  
Similar to the NLS objects, their scope is limited to the file where they are declared.  
We can use the import instruction to import a file that contains many Mappings. Like that they can be declared once and used in many pages.  

The default project includes some mappings in the file :  
`ProjectFolder/webportal/pages/resources/mappings.page`.  
Those mappings are ready to use and can be imported in any page. See the list of examples for more detail.  

Mappings can be used with the Transform keyword. As a best practice, the return value of mapping should use the according NLS.  

Transform variable using `mappingIdentifier`.  

There are several kind of mappings depending of the type of variable.  

## StringMapping

To modify string values. Syntax:  

```page
mappingIdentifier = StringMapping {
    when "value1" then $nls.value
    otherwise current
}
```

When the received variable matches "value1" it will change it to use the NLS value $nls.value. Otherwise , value will not be changed.

## BooleanMapping

To modify boolean values. Syntax:  

```page
mappingIdentifier = BooleanMapping {
    when True then $nls.value
    when False then $nls.value2
}
```

## IntMapping

To modify Integer values. Syntax:  

```page
mappingIdentifier = IntMapping {
    when InvalidInteger then 0
    when >10 then 10
    otherwise current
}
```

If the value is invalid then it will return 0, if its greater than 10 it will return 10. In any other case, the value will not be changed.  

## DateMapping

To retrieve a string based on a date condition. Syntax:  

```page
tooLateMapping = DateMapping {
 when DateAfter current then "too late"
 otherwise "ok"
}
```

If the given date if after the current date/time, returns "too late", otherwise returns "ok".  
Allowed conditions are DateAfter, DateBefore, DateBetween, Not, TimeAfter, TimeBefore, TimeBetween.

## Examples

Some of the examples of mapping provided with the default project:  

```page
optionStringMapping = StringMapping {
 when IsEmpty then $global.novalue
 otherwise current
}
```

This very useful mapping will return an "No Value" when a string is empty. Like that we don't see "Null" in the page.  

```page
reconciliationStatusMapping = StringMapping {
  when "orphan" then $reconciliation.status.orphan
  when "reconciled" then $reconciliation.status.reconciled
  when "leave" then $reconciliation.status.leave
  when "noowner" then $reconciliation.status.noowner
  otherwise current
}
```

This mapping will transform the reconciliation code into a user-friendly value using NLS.  

```page
nullToZeroMapping = IntMapping {
 when InvalidInteger then 0
 otherwise current
}
```

If the value of the integer is invalid, then it will be set to 0, this will avoid "Null" values  
