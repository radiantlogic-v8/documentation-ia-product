---
title: Advanced Concepts
description: Advanced Concepts
---

# Advanced Concepts

## JavaScript expressions

Since version 2017 R3, you can use JavaScript expressions directly in pages, both in bindings and in predicates.  

### Bindings

You can either use string interpolation, for example in:  
`Set "Infos: {param1.get()} - {config.logPath} - {principal.login}" to var3`  

Inside the string, expressions enclosed between { and } are evaluated as JavaScript expressions and their value replace the expression.  

You can also use expressions with the Eval keyword as in:  
`Join Eval "'a,b,c,d'.split(',', 2)" using "|"`

will evaluate to the string `a|b`.  

### Predicates

You can also use JavaScript expressions in a predicate (an expression evaluating to a Boolean value):  
`disabled: Eval "var1.isEmpty() || var2.isEmpty()"`

### Accessible objects

Inside a JavaScript expression, you can use:

- variables (for example `"{var1.get()}"`),
- parameters (for example `"{param2.get()}"`),
- record columns using \<record name\>.\<column name\> (for example `"{identity.fullname}"`),
- task record attributes using \<task name\>.\<attribute name\> (for example `"{task.org_uids.length}"`),
- process record attributes using \<process record name\>.\<attribute name\> (for example `"{process.uids.get()}"`),  
- user variables using uservariable.\<user variable name\> (for example `"{uservariable.selectedApplications.get()}"`)
- current values in a dataset iteration using current.\<column name\> (for example `"{!current.altname.isEmpty()}"`),
- configuration variables using config.\<variable name\> (for example `"{config.logPath}"`),
- principal attributes using principal.\<attribute name\> (for example `"{principal.login}"`).

> For record columns, current values, configuration variables and principal attributes the value can only be mono-valued by construction, so it is already a simple type (string, date, boolean, etc...).

## Javascript Services

Javascript files can now be created inside the webportal/pages directory (and any sub-directories) and methods from these files can be referenced by services. The extension of these files must be '.javascript'.  

The service declaration block now allows the new attributes:  

- javascript-file: the name of the javascript file, relative to the root of the project,  
- javascript-method: the name of a method in the previously specified file.  

The method should not have parameters and, for StringService, IntService and BooleanService, return a value of the appropriate type. For EventService any return value is ignored.  

Inside the method, the dataset object already contains attributes for any input or output parameter specified in the service declaration.  

For example in the `/webportal/pages/test_js.javascript` file  

```page
function test12() {
    if (dataset.invert.get()) {
        return dataset.surname.get() + " " + dataset.givenname.get();
    }
    return dataset.givenname.get() + " " + dataset.surname.get();
}
```

and in a `.page` file  

```page
js12 = StringService {
    javascript-file: "/webportal/pages/test_js.javascript"
    javascript-method: test12

    givenname = Input {
        type: String
        mandatory: True
    }
    surname = Input {
        type: String
        mandatory: True
    }
    invert = Input {
        type: Boolean
        default: False
    }
}

test_js3 = Page {
    title: "[JS] Assignable Services in Table"
    tags: "TEST", "GENERAL"

    invert = Variable {
        type: Boolean
        initial: False
    }

    identities = Dataset {
        view: br_identity
    }

    Checkbox {
        variable: invert
        text: "Invert"
        modify-event: ReloadData(identities)
    }
    Table {
        data: identities
        label: Label {
            break: True
        }
        layout: Layout {
            grab: horizontal True vertical True
        }
        show-count: True

        Column {
            column: uid
            header: "UID"
            width: 300px
        }
        Column {
            column: fullname
            text: @js12(Current givenname to givenname, Current surname to surname, invert to invert)
            header: "Name"
            width: 100%
        }
    }

}
```

The config object can be used to retrieve project global variable as defined in the configuration files, as well as four other attributes:  

- `__PRINCIPAL_UID` is the uid of the user viewing the page,  
- `__PRINCIPAL_FULLNAME` is the full name of the user viewing the page,
- `__PRINCIPAL_LANGUAGE` is the language of the user viewing the page,
- `__TIMESLOT_UID` is the timeslot of the current page.  

For example, in the javascript file:  

```page
function test11() {
    dataset.out_val = config.__PRINCIPAL_UID + "/" + config.__PRINCIPAL_FULLNAME
    + " (" + config.__TIMESLOT_UID + ")";
}
```

and in the page  

```page
js11 = EventService {
    javascript-file: "/webportal/pages/test_js.javascript"
    javascript-method: test11

    out_val = Output {
        type: String
    }
}

test_js2 = Page {
    title: "[JS] Event Services"
    tags: "TEST", "GENERAL"
    enter-event: Call js11(out_val from out_val)

    out_val = Variable {
        type: String
    }

...

}
```

You can call a View or a Rule by using the following syntax:  

```page
function getTotalAccounts ( file_uid , extras ) {
 var params = new java.util.HashMap();
  params.put("uid", file_uid );
  var res = connector.executeView(config.__TIMESLOT_UID, "files_countaccounts" , params);
  extras[0]  = res[0].get("share_displayname").toString();
  extras[1]  = res[0].get("code").toString();
  return Number(res[0].get("total_active_accounts"));
}
```

Inside the javascript, any print call will be redirected to the igrcportal.log file. The debugger; token can be used to dump a bunch of information in the log file (which must allow debug level).

## Nationalization strings with parameters

You can be in a situation where you want to create dynamic nationalized texts, including some information extracted from a variable, a record, ...  

one method could be to use the Concat keyword :  

```page
parts = NLS {
  part1 [en "the account " fr "le compte "]
  part2 [en " has too many permissions" fr " a trop de droits"]
}

demo = Page {
 title:'test'

 login = Variable{initial:'jdoe'}

 Text {
    value:Concat($parts.part1, login, $parts.part2)
 }
}
```

This is not a good practice as it implies that you specifically code the concatenation, thus you won't be able to update the labels easily.  
You can instead use NLS parameters.

NLS strings accept parameters, those parameters are leveraged by the {NUMBER} pattern, starting with 0.  

We can rewrite the above example in the following form:  

```page
parts = NLS {
  part [en "the account {0} has too many permissions" fr "le compte {0} a trop de droits"]
}

demo = Page {
 title:'test'

 login = Variable{initial:'jdoe'}

 Text {
    value:$parts.part(login)
 }
}
```

As you can see, `{0}` is used to specify where the dynamic value will be located in the string.  
This dynamic value is passed as a parameter of the NLS entry: `$parts.part(login)`  

You can have several parameters as well:  

```page
parts = NLS {
  part [en "the account {0} from {1} has too many permissions" fr "le compte {0} de {1} a trop de droits"]
}

demo = Page {
 title:'test'

 login = Variable{initial:'jdoe'}
 name = Variable{initial:'John Doe'}

 Text {
    value:$parts.part(login, name)
 }
}
```

You just have to increment the index within the {...} and to specify several parameters separated by a ','  .  
You can also apply a specific text formatting for integer, boolean or date parameters.  

Here is an example:  

```page
parts = NLS {
  part [en "Orphan account ratio {0,number,#.##}%" fr "Ratio de comptes orphelins {0,number,#.##}%"]
}

demo = Page {
 title:'test'

 val = Variable{initial:77.54678}

 Text {
    value:$parts.part(val)
 }
```

You can refer to [Java 7 Message Format](https://docs.oracle.com/javase/7/docs/api/java/text/MessageFormat.html) for more details about this.  

## Conditional nationalization

You can embed tests in your nationalization strings in order to build different strings depending on its dynamic content.  

Let's take a simple example: You can to display a warning dialog box if some entries still need to be reviewed.  
You want to display a different message depending on the number of elements left for review: 1 or several elements.  

Here is an example:  

```page
reviewNLS = NLS {
    commitwarning [en "{0,choice,1#{0} entry still need to be reviewed|1<{0} entries still need to be reviewed}" fr "{0,choice,1#Il reste {0} entrée à revoir|1<Il reste {0} entrées à revoir}"]
}


review = Page {
    title:'demo'

    nbelements = Variable{initial:3}


    Button {
        actions:Confirm $reviewNLS.commitwarning(nbelements)
    }
}
```

As you can see, you can add a context within {...} such as conditions.  

You can refer to [Java 7 Message Format](https://docs.oracle.com/javase/7/docs/api/java/text/MessageFormat.html) and [Java 7 Choice Format](https://docs.oracle.com/javase/7/docs/api/java/text/ChoiceFormat.html) for more details about this.  

## Conditional Redirect

You can attach a condition on a Page or a Report in order to trigger a redirect based on a condition.  
The condition will be tested once the page has been loaded, it means that this condition can leverage data from the Identity Ledger through Dataset and Record objects.  

This can be useful for instance if you want to redirect the user based on the kind of data that he tries to access to.  

Let's take a simple example:  

you create 3 Account Analytics pages:  

- one page which will be the default analytics page
- one page dedicated to SAP accounts
- one page dedicated to Active Directory accounts  

When you redirect the user to this accounts analytics section, you want to dynamically display the right content based on the account repository.  

You can do it by redirecting the user to the default analytics page, and by attaching  a conditional redirect in the default analytics page to redirect the user to the SAP page or the Active Directory page, depending on the account repository.  

What you can do as well is to dynamically compute a parameter based on another parameter, here is an example:  

```page
accountDetailsPageRecorduid = Page {
 title: "Recorduid redirection (account)"
 conditional-redirect: ConditionalRedirect { condition: True target: Page accountDetailsPage with accountUid.uid to paramAccountUid }

 recorduid = Parameter {
 type: Integer
 hidden: True
 recorduid-of: Account
 mandatory: True
 }

 accountUid = Record {
 view: br_accountDetail_uid with recorduid to recorduid
 }
}
```

When you redirect a user on this page with a recorduid parameter, it automatically retrieve the uid based on the recorduid and redirect the user back to the account details page.  

As you can see, you only have to fulfill the conditional-redirect property with a ConditionalRedirect object.  
**condition**: contains the condition (must return true or false, see [conditions](./20-events-and-actions.md)for more details)  
**target**: contains the target (see the [GoTo](./20-events-and-actions.md) instruction for more details)  
