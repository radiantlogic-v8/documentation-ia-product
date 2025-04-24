---
title: Macros
description: Using macros in notification rules
---

# Macros

## Customization  

To customize notification rules, the information provided by the ledger is used in the different sections of your email such as subject, body or reports. These values can then change dynamically for each recipient. A common example is the first line of the message: instead of a generic greeting, it is possible to have "Dear John Doe".  

To do so, the notification rules use a view to retrieve all the customizable information. This include the identities information, as well as their associated information (_e.g._ organization, permissions, applications, ...). Macros, then, allow us to insert this information into the email's fields. Here is an example, concerning the greeting:  
`Dear {dataset.fullname.get()}`  

A macro is a javascript expression that is evaluated when the notification rule is run or when the email is sent. The notification rule processes the recipients and evaluates the macros for each field, one by one. The macros are replaced by the computed value and the mail is sent.  

Within a macro expression, the keyword dataset, which is a Javascript object, refers to a line returned by the view. All of the returned attributes are available. For instance, if the view returns the hrcode attribute, it is possible to use it in the message using the following syntax:  
`Your HR Code is {dataset.hrcode.get()}`  

If a macro using the dataset keyword is used, then it implies that the email content will be different for each recipient. One email will be sent for each recipient. If no macros are used, the notification rule will send the same email to all recipients.  

There are other javascript objects that allow access, for instance, to the configuration variables of the project, or to embedded images. The dataset object is the only macro that will result in sending multiple different emails, one for each recipient.  

The content of a macro can be more complex than the above examples and use other javascript functions. For instance, if you want to display "Dear John DOE", setting the surname to uppercase:  
`Dear {dataset.givenname.get()} {dataset.surname.get().toUpperCase()}`

## How to use Macros  

There are 5 Javascript objects at you disposal in a notification rule:  

- dataset: provides access to the view's attributes (current row)
- image: references the images included in the notification rule
- param: the notification rule's parameters (as declared in the first tab)
- config: project configuration variables  
- task: the current task of a workflow  

Here is the list of fields in which you can use these objects:  

| Objects                    | dataset | image | param | config | task  |
| :------------------------- | :-----: | :---: | :---: | :----: | :---: |
| Sender name                |         |       |   x   |   x    |       |
| Sender mail                |         |       |   x   |   x    |       |
| CC e-mail list             |    x    |       |   x   |   x    |       |
| BCC e-mail list            |    x    |       |   x   |   x    |       |
| Message subject            |    x    |       |   x   |   x    |   x   |
| Body (HTML)                |    x    |   x   |   x   |   x    |   x   |
| Reports \> Report name     |    x    |       |   x   |   x    |   x   |
| Reports \> Parameter value |    x    |       |   x   |   x    |   x   |

### Using multivalued attributes

Macros only contain Javascript expressions, so it is not possible to iterate on all the values of a variable. For instance, if the "applications" parameter contains a list of applications that we want to display in the body, it is not possible to iterate on it.  
To compensate this, a function called "format" has been added to the String class. This method is useful to display multivalued information in the message's body. Its syntax is as follows:  
`String.format(formatStr, separator, repeatLastValue, params, ...)`  

The idea is to provide this method with a formatting and a list of values, so that the engine will format the values. The method will be called as many times as there are values in the list, and replace {0} with each value. For instance, if we want to display the list of applications in one line, separated by commas, we can write:  
`Applications : {String.format("{0}", ",", false, param.applications)}`  

The result will be similar to:  
`Applications : Elyxo,Exchange,SAP`  

Following you will find the description of the methods and parameter:  

**Goal** : returns a formatted string that follows the model provided as an input. This model also respects the mono or multi-valued character of the parameters. This method iterates on the format as many times as there are values in the longest list. If there are at least two iterations, the separator is inserted between the formats. When all the parameters contain a different number of values, the "repreatLastValue" parameter allows to repeat the last value of shorter lists to fill in the gap. Take for instance this expression: String.format("{0} works in {1}", ";", true, dataset.surname.get(), dataset.organizations). If dataset.organization contains 2 organizations, the result will be : "John works in DRH;John works in DCOM".  

**Return value** : returns a formatted String following the model passed as the "formatStr" argument.  

**formatStr parameter** : returns a string containing the formatting model for the parameters. The format follows the specifications of the java.util.MessageFormat class. Two specific strings have been added: {n} is replaced by the iteration counter starting at 0 and {N} by the iteration counter starting at 1.  

**separator parameter** : returns a string inserted between each iteration.  

**repeatLastValue parameter** : is true if the last value of each list has to be repeated to fill in the gaps with the longest list  

**params parameters** : from 1 to n parameters used in the formatting model via the {0} {...} {n} syntax.  

Let's look at a more complex example. There are two lists of values of the same size: applications which contains a list of applications, perms which contains the number of permissions for each application. We would like to display the following result in the sent email:  

```txt
Applications : Application Elyxo with 3 permissions,
Application Exchange with 50 permissions,
Application SAP with 302 permissions
```

This is a simple text without HTML formatting (no bullets or tables). The source code to obtain this result is:

```txt
  Applications : {String.format("Application {0} with {1} permissions", ", ",
  false, param.applications, param.perms)}
```

## Field encoding  

Macros, once evaluated produce a text that will replace the macros definition in the brackets. In the case of the HTML body, the text from the result of a macro is automatically escaped from HTML in case the text would contain special characters (for instance the sign \< that is the start of an HTML tag).  

In the previous chapter, String.format is used to generate simple text that is automatically escaped from HTML. If we want to generate a table with borders, we have to design the formatting model (first parameter of String.format) to produce HTML tags. We have to set the function not to escape HTML characters by putting a $ sign just after the opening bracket `{`. Here is what we want to generate:  

| Application name     | nb permission   |
| :------------------- | :-------------- |
| Application Elyxo    | 3 permissions   |
| Application Exchange | 50 permissions  |
| Application SAP      | 302 permissions |

To get this result, you have to write:  

```html
<TABLE>{$String.format("<TR><TD>Application {0}</TD><TD>{1} permissions</TD></TR>", ", ",
false, param.applications, param.perms)}</TABLE>
```

The $ indicates that the content generated is already in HTML format. This is only necessary in the email body, since this is the only content in the HTML format.

## Javascript objects description  

This chapter describes the content of the available javascript objects in the different email fields.

### Information on the recipient  

Name: dataset  

Description : this object contains all the characteristics of the recipient. It is of type Dataset and contains properties of type Attribute that are determined by the view's attributes.  

Properties: all the fields returned by the view. Each attribute is of type Attribute, which means that dataset.applications is of type Attribute. The attribute's values types are determined by the view. To get the first value, use the .get() method on Attribute: `dataset.applications.get()`  

Methods: all the methods available on dataset  

Cardinality: a view returns only monovalued attributes, but since the notification rule groups the view's results by email, the other attributes values are aggregated in multivalued attributes. If the option "Handle each view result in a different e-mail (no grouping on e-mail address)" is checked, all the attributes are mono-valued.  

### Embedded Images  

Name: image  

Description : this object contains the list of embedded images in the email body. It is of type Image and contains only properties of type String.  

Properties: all the image identifiers. Each value of each property is the URL allowing the email client to display the image in the HTML message. Therefore, you should not call the .get() property since the property is already the URL String. The common usage is to insert an img tag as follows:  
`<img src="[image.myicon}">`  

Methods:none  

## Rule parameters

Name: param  

Description: this object contains the list of the notification rule's parameters. It is of type Dataset and its properties are of type Attribute. The properties can be mono- or multi -valued. Since each parameter is of type Attribute, this means that param.applications is of type Attribute. Inside the attribute, the values are of the type defined in the first tab of the notification rule. To get the first value, call the .get() method on Attribute, for instance: param.applications.get().  

Properties: all the parameters of the notification rule.  

Methods: the same as Dataset.  

### Configuration variables  

Name: config  

Description : this object contains the list of configuration variable of the project. It is of type Config and contains properties of type String. The value of each property is a mono valued String. No need to use the .get() method to get the value.  

Properties: all the project variables  

Methods: none  

## Workflow's current task  

Name: task  

Description : this object gives information on the current task when the notification rule is called by the workflow (to notify a candidate for instance). It is of type Dataset.  

| **Properties**         | **Type** | **Multivalued** | **Description**                                                                                                                                                                                |
| :--------------------- | :------- | :-------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| listOfFormattedUrls    | String   | Non             | A HTML string containing the list of URLs to take the task (must be prefixed by $ as follows: {$task.listOfFormattedUrls.get()}). The text generated uses the language defined in the project. |
| url                    | String   | Non             | URL to take the task                                                                                                                                                                           |
| delegatedUrls          | String   | Oui             | List of URLs to take the task as delegate                                                                                                                                                      |
| delegatorFullnames     | String   | Oui             | List of the delegates' fullnames                                                                                                                                                               |
| title                  | String   | Non             | Title of the task                                                                                                                                                                              |
| description            | String   | Non             | Description of the task                                                                                                                                                                        |
| type                   | String   | Non             | Type of the task                                                                                                                                                                               |
| roleName               | String   | Non             | Name of the role associated to the task                                                                                                                                                        |
| roleDescription        | String   | Non             | Description of the role associated to the task                                                                                                                                                 |
| startDate              | Date     | Non             | Task start date                                                                                                                                                                                |
| dueDate                | Date     | Non             | Task due date                                                                                                                                                                                  |
| processCreatorFullname | String   | Non             | Fullname of the person having started the process                                                                                                                                              |
| processTitle           | String   | Non             | Title of the process                                                                                                                                                                           |
| processStartDate       | Date     | Non             | Process start date                                                                                                                                                                             |

Methods : same as the dataset
