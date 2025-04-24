---
title: Widgets
description: Widgets 
---

# Widgets

## Introduction

Widgets objects can be found in the widget block of a page. They don’t require an identifier, so the syntax to include them is simply:

```page
Widget {
  attribute: value
}
```

All the elements of a page are widgets that are rendered to be displayed or to interact with the users.  
They can be used to display information that was retrieved using the datasets and can also interact with the user to allow them to select items and more.  
We have many widgets available, they have been classified by their main purpose into 4 categories:  

- [Container widgets](./08-containers-widgets.md)
- [Display widgets](./09-display-widgets.md)
- [Selection widgets](./10-selection-widgets.md)
- [Edition widgets](./11-edition-widgets.md)
- [Chart widgets](./12-chart-widgets.md)
- [Iterable widgets](./13-iterable-widgets.md)
- [Special widgets](./14-special-widgets.md)

The configuration of the widgets is done basically by providing values to a list of attributes. Some of them have available a very specific list of attributes, but there is also some attributes that can be used with almost all widgets. This is what we consider the list of commons attributes.

## Common Attributes

### Layout Attribute

**layout** is an attribute that allows us to configure a set of options related to the layout and display of each widget.  

Almost all widgets that need to be rendered and will take some space in the final delivered version of the page support this attribute.  

This is an attribute with a particular value, because it takes only an object of type **Layout**.  

`layout: Layout {}`  

The layout object supports many attributes that are all optional and can be combined together:  

**grab** defines if the widgets will take all the space that is available for him. It takes two boolean values: one for vertical and one for horizontal  

`Layout { grab: horizontal True vertical True }`: will take all the space possible in both directions  

`Layout { grab: horizontal False vertical True }`: will take all the space possible only in vertical  

**align** defines how should the widget should be aligned. It takes two values, one for vertical and one for horizontal. The options are : Beginning , End , Center, Fill  

`Layout { align: horizontal End vertical Beginning }`: will align the widget to the right upper corner  

> Note that if a widget is grabbing all the space, the align will have no effect  

**hint** is used to define an specific desired size for the widgets. It takes two numbers, one for height and one for width. the measures are considered in pixels.  

`Layout { hint: height 100 width 100 }`: will take a space of 100x100 px  

**indent** is used to create a margin: it takes two numbers, one for vertical and one for horizontal. the measures are considered in pixels.  

`Layout { indent: horizontal 10 vertical 10 }`: will indent the widget 10px from the top and from the left  

**minimal** designs a minimal size for the widget: it takes two numbers, one for height and one for width. the measures are considered in pixels.

`Layout { minimal: height 100 width 100 }`

### Background Attribute

Background allows to set the background of a widget. Its normally supported in containers widgets.

It can contain as a value 3 types of objects:  

- `background: Color`: Color offers many options to define a color, Crtl + space is recommended to browse them.  
Some keywords for colors are supported like:  
  - `background: Color red`  
  - `background: Color blue`  
  - Or also combinations of color using for example RGB:  
  - `background: Color RGB (10,10,10)`  
- `background: Image`: Image gives the option to specify a path to an image  
  - `background: Image "background.png"`  
  - Note that the root for images is ProjectPath/reports/icon, so "background.png" will be located in ProjectPAth/reports/icon/background.png  
- `background: None`: No background  

### Feature Attribute

Feature attribute can make reference to a feature that was previously defined in one of the .features file.  

This will link the widget to a feature. And only the users we have this feature will be able to see and interact with the widget.  

Syntax is straightforward:  

`feature: featureIdentifier`  

For more on features take a look to the [features and roles segment](./features-and-roles/index.md).  

### Styling Attribute

Styling attribute can be used to modify the font, color , size and background of text.  

To do this we must first take a look to the Style object. Style objects are declare as :  

```page
detailsLabel = Style {
 foreground: HEX ( #474747 )
 bold:True
 size: 12px
}
```

Style objects are not part of the page. They must be declared outside and can be imported. Just like NLS objects.  

As a best practice, all required styles can be declared in an independent file styles.page and can be imported from many pages.  
This will make it easy to use them and to change them when needed.  

After the style is defined or imported , the Syntax to assign it to a widget is straightforward:  

`styling: styleIdentifier`  

Additionally, Styles can be assigned conditionally, using structures that are very similar to the Predicate functions:  

```page
styling: BooleanStyling ( booleanVariable ) {
  when True then detailsLabel
  when False then default
}

styling: StringStyling ( pageVariable ) {
  when "value" then detailsLabel
  otherwise default
}

styling: IntStyling ( pageVariable ) {
  when =0 then detailsLabel
  otherwise default
}


styling: DateStyling ( dateVariable ){
  when DateAfter Date("31/12/2016") then detailsLabel
  otherwise default
}
```

The `default` keyword can be used to reference the default style.  

### Mixins Attribute

Mixins are objects that can be used to define a template of attributes values that will be applied to several objects.  

For example, the mixin objects:  

```page
detailsMixin = Mixin {
  Label {
    styling: detailsLabel
  }
  Text {
    compact:True
    styling: detailsText
    align: Left
  }
  Link {
    styling: detailsLink
  }
}
```

In this mixin we set a list of attributes to 3 kind of object: Labels, Texts and Links.  

A mixin works like a template, in the example the templates says:  

- All labels should use the style detailsLabel
- All Texts should use the style detailsText
- All Texts should be compact and aligned to the left
- All Links should use the style detailsLink

By itself, the mixin does nothing. To use it , we need to set it to a widget that supports mixins. The syntax:  

`mixins: detailsMixin`  

If we assign this mixing to a Group then all the children will take this styles and attributes. For example:  

```page
Group {
  mixins: detailsMixin
  Text {
    label: "label"
    value: "example"
  }
}
```

Because we define the mixin, the Text will be styled with detailsText, and the label will be styled with detailsLabel.  

Like this, the purpose of the mixin is to reduce the repetition of attributes. They can be defined only once and be used in many places.  

As with NLS and Styles, the mixins objects are not part of the page, they are declared outside and can be imported.  

A good practice is to keep them in the same place of the Style objects.  

### Hidden Attribute

The hidden attribute is very simple, it can be used to hide widgets that should not be displayed.  

The most common use of the hidden attributes is when we must hide a widget conditionally depending on the value of a variable.  

The syntax is very simple:  

> hidden: booleanValue

We can use a fixed value like True/False , but to make it useful we can combine this with any of the [Predicate functions](./16-predicate-functions.md).

The predicate function will return True or False depending on the value of a variable, parameter or record column:  

```page
Group {
  hidden: StringPredicate ( selectedIdentityUid ){
    when IsEmpty
    then True
    otherwise False
  }
}
```

This group will be hidden when the variable selectedIdentityUid is empty.
