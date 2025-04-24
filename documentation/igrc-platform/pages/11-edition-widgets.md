---
title: Edition Widgets
description: Edition Widgets
---

# Edition widgets

Edition Widgets are generally linked to a variable.  

They will display the value of the variable, but they will also allow to user to interact and modify its value.  

![Edition Widgets ](./images/1601.png "Edition Widgets ")  

## Edit

For string variables:  

```page
Edit {
 variable: pageVariable
 label: "Edit Example"
}
```

![Edit](./images/1603.png "Edit")  

## Combo

For string variables in a combobox. Here the values come from a list (static or dataset).  

```page
Combo {
 variable: selectedIdentityUid
 label: "Combo Example"
 options: Dynamic {
 data: sourceData
 text: Current fullname
 value: Current uid
 }
}
```

![Combo](./images/1604.png "Combo")  

## DateTime

For Date variables:  

```page
DateTime {
 variable: dateVariable
 type: Date
}
```

![DateTime](./images/1605.png "DateTime")  

## Checkbox

For a boolean variable:  

```page
Checkbox {
 variable: booleanVariable
 label: "Checkbox Example"
}
```

![Checkbox](./images/1606.png "Checkbox")  

## RadioButtons

For limited options:  

```page
RadioButtons {
 variable: pageVariable
 label: "RadioButtons Example"
 Option {
 text: "Yes"
 value: 1
 }
 Option {
 text: "No"
 value: 0
 }
 Option {
 text: "Maybe"
 value: 3
 }
}
```

![RadioButtons](./images/1607.png "RadioButtons")  

## Scale

For integer variables:  

```page
Scale {
 variable: pageVariable
 label: "Scale Example"
 minimum: 0
 maximum: 100
 increment: 10
 show-value: Right
}
```

![Scale](./images/1608.png "Scale")  

## Spinner

For integer variables:  

```page
Spinner {
 variable: pageVariable
 label: "Spinner Example"
 minimum: 0
 maximum: 100
 increment: 10
}
```

![Spinner](./images/1609.png "Spinner")  

## MultiEdit

For multivalued variables :  

```page
MultiEdit {
 add-dialog: identityPicker returning outDisplayname
 buttons-presentation: Icon
 Element {
 variable: multivaluedVariable
 }
}
```

![MultiEdit](./images/1610.png "MultiEdit")  

## Upload

To upload files:  

```page
Upload {
 variable: pageVariable
 hide-comment: True
 show-controls: True
}
```

![Upload](./images/1611.png "Upload")  
