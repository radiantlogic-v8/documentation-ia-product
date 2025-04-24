---
title: Predicate Functions
description: Predicate Functions
---

# Predicate functions

In many cases we have some attributes that require Boolean values.
For example: hidden or disabled  
Of course we can always set this value directly to True or False, in to make these functionalities useful, we will need to test the values of variables, parameters or records.  
Being able to test those values and to specify the conditions that will lead to True or False allows us to implement useful interfaces.  

For example, we can hide or display a group based on the value of a variable. This variable can be set as the target of a selection widget for instance. This way, we can adjust the interface responding to user interaction.  
The structures to test values are called Predicates and we have many options depending of the variable type.

## StringPredicate

The string predicate takes as a parameter one string variable,  parameter or record column. The general structure is :  

```page
StringPredicate ( variable ) {
    when "value" then True/False
    when IsEmpty then True/False
    otherwise then True/False
}
```

We can have several conditions that will be evaluated in order, and we can always end with the keyword otherwise. The return value of a predicate should always be True or False.  

For example:  

```page
Group {
    hidden: StringPredicate ( selectedIdentityUid ){
        when IsEmpty then True
               otherwise False
    }
}
```

This group will be hidden when the variable selectedIdentityUid is empty.  

## IntPredicate

The int predicate takes as a parameter one integer variable, parameter or record column. The general structure is :  

```page
IntPredicate ( variable ) {
    when InvalidInteger then True/False
    when = 0 then True/False
    when < 10 then True/False
    otherwise True/False
}
```

We can have several conditions that will be evaluated in order, and we can always end with the keyword otherwise. The return value of a predicate should always be True or False.  

For example:  

```page
Group {
    hidden: IntPredicate ( selectedIdentityRecorduid ){
     when InvalidInteger then True
     when =0 then True
     otherwise False
 }
}
```

This group will be hidden when the variable selectedIdentityRecorduid is an invalid integer or equals 0.  

## BooleanPredicate

The boolean predicate takes as a parameter one boolean variable, parameter or record column. The general structure is :  

`BooleanPredicate( variable )`  

There are no conditions and the result will be the value of the variable.  

For example:  

```page
Group {
    hidden: BooleanPredicate ( showMore )
}
```

This group will be hidden when the variable showMore is True.

## DatePredicate

The date predicate takes as a parameter one Date variable, parameter or record column. The general structure is :  

```page
DatePredicate ( variable ) {
    when DateAfter DateLDAP(date) then True/False
    otherwise True/False
}
```

We can have several conditions that will be evaluated in order, and we can always end with the keyword otherwise. The return value of a predicate should always be True or False.  

The supported keywords for when are: DateAfter, DateBefore, DateBetween, TimeAfter, TimeBefore, TimeBetween.  

For example:  

```page
Group {
 hidden: DatePredicate (date){
 when DateAfter DateLDAP ( "20161231" ) then True
 otherwise False
 }
}
```

This group will be hidden when the variable date is after the given date 20161231.  

## MultivaluedPredicate

The multivalied predicated can test if a value is contained in a multivalued variable.  

For example:  

```page
Group {
    hidden: MultivaluedPredicate ( multivaluedVariable contains "value")
}
```

This group will be hidden when "value" is part of the variable multivaluedVariable.

## FeaturePredicate

The feature predicate test if the current user has the given feature. Syntax is bit different:  

`FeaturePredicate feature_id`  

There are no parenthesis and no conditions. It will be True if the user has the given feature.  

For example:  

```page
Group {
 hidden: Not FeaturePredicate seeMore
}
```

This group will be hidden if the user has the feature seeMore.

## Boolean Operations

Before taking a look ad the predicate functions, it is important to know that all Predicate functions will return a boolean value (True/False).  
All boolean values can be transformed to the opposite value using the keyword Not.  

For example:  

```page
Group {
 hidden: Not FeaturePredicate seeMore
}
```

This group will be hidden if the user does not has the feature seeMore.  

It is also possible to combine different Predicate functions together using the AndPredicate and OrPredicate, the structures:  

```page
AndPredicate {
    Predicate1
    Predicate 2
}

OrPredicate {
    Predicate1
    Predicate 2
}
```

For example:  

```page
Group {
    hidden: OrPredicate {
 BooleanPredicate( variable1 )
 BooleanPredicate( variable2 )
    }
}
```

This group will be hidden when either variable1 is True or variable2 is True.
