---
title: Internationalization
description: Internationalization
---

# Internalionalization i18n

The pages language includes a mechanism that facilitates the development of pages that are to be presented in different languages.
This is done through the use of the NLS object.  

## NLS Objects

The object type: **NLS** represents a custom key-based structure. Each message or text block that needs to be translated will be identified with a key. Then we can assign to each key the different values that it should take depending on the language :

```page
nameOfThePageNLS = NLS {
 title [en "Title" fr "Titre"]
 description [en "Description" fr "Description"]
}
```

We can reference one message by using its key from anywhere in a page when we want to display a text value. For example:  

```page
nameOfThePage = Page {
 title: $nameOfThePageNLS.title
 description: $nameOfThePageNLS.description
}
```

Keys can also be organized in a tree-based hierarchy :  

```page
nameOfThePageNLS = NLS {
 title [en "Title" fr "Titre"]
 description [en "Description" fr "Description"]
 section1.title [en "Details" fr "Détails"]
}
```

In which case it will be used like: `$nameOfThePageNLS.section1.title`

## Scope

NLS objects are not part of the page. They are declared in .page files and they can be used anywhere in the file.  
These objects are optional. As a best practice, we can declare one NLS object per file and its declared before the page.  

In a page, we can reference an NLS declared in another page. We do using the `import block`.  

We can create a .page files that contains only NLS objects and we can import the file into all other pages. This kind of pages already exists for well-known values, they can be imported using the following syntax :  

```page
import "/webportal/pages/resources/concepts_nls.page"
import "/webportal/pages/resources/pages_nls.page"
```

After importing these pages we can make reference to for example: `$identity.fullname`  

These pages will provide translations to French and English of some commonly used terms.

## Properties files

It is possible to externalize internationalization of strings in `.properties` files. This facilitates the translation process.  
These files must be located in the project in the directory `webportal/pages` or any of its sub-directories.  

Their name must conform to the format `<name>_\<code>`.properties where `<name>` is the base name of the file and `<code>` is a 2 or 3 letters **ISO 639-1** or **ISO 639-2** code for the translated language.  
Entries inside these files should be formatted as `<nlsName>.<tag>=<translated text>` where `<nlsName>` is the name of a NLS element defined in a page, `<tag>` is a tag belonging to said NLS and `<translated text>` is the translation for the corresponding language.  
All the `.properties` files are merged together at the start of the portal and are used when a NLS declared in a page does not provide an entry for the user's language.  
For example if you have in a page the NLS:  

```page
nameOfThePageNLS = NLS {
 title [en "Title" fr "Titre"]
 description [en "Description" fr "Description"]
 section1.title [en "Details" fr "Détails"]
}
```

you can create a `translation_es.properties` file containing the following Spanish translations:  

```page
nameOfThePageNLS.title=Título
nameOfThePageNLS.description=Descripción
nameOfThePageNLS.section1.title=Detalle
```

Entries in this file will be used for a user using any es locale.

## Customizing the list of supported languages in the portal

By default, the portal will use the language configured in the user's browser configuration to display information. However, in his preference page, a user can choose to override this browser configuration by selecting another language from a combo box.
The list of languages from which he can choose can be modified using the `interface.supported-locales` variable in the technical configuration. This variable contains a list of comma separated entries `<language code>=<label>` where `<language code>` is a 2 or 3 letters ISO 639-1 or ISO 639-2 code and `<label>` is the value displayed in the combo box. For example:  
`en=English,fr=Français,es=Español,pt=Português,ja=日本語`

## More information

For more information on nationalization please check the following page:

[Advanced Concepts](./22-advanced-concepts.md)
