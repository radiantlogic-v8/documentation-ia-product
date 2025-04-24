---
title: Add-ons
Description: Documentation related to the creation, the installation and the usage of Add-ons
---

# Add-on Creation

## Build your Facet

Once you are satisfied with the content of your facet, you can build the .facet file that can be installed in other Identity Analytics projects. To do this, simply select the action **Build facet** in the **Build** tab. The files that will be included in this build are listed in the table at the bottom of the screen. The empty facet directories are not shown in this list and will be discarded.  

![Build](../add-ons/images/build.png "Build")

The build action will create a facet file with the correct name and version in the `facets_infos/facets_outputs` folder of the project. Beware that, it will overwrite the file if it already exists.  

![Output](../add-ons/images/output.png "Output")

## Work with Variables

Some facets require user input to function properly (a file or folder path, a repository name, ...). The best way to deal with this is to define [configuration variables](../technical-configuration/technical-configuration.md).  

In a `.configvariable` file included in the facet, and to use them where this information is needed (a discovery file, a collector line, etc). This ensures that your facet project is running completely with the values inside you local configuration, and that, during facet installation, the user will be prompted for those values.  

Please note that your configuration variables will be automatically renamed in the user project, to avoid naming conflicts, so that you do not need to choose elaborate naming patterns just for this purpose. In the configuration editor, the variables will be clearly stated as having the facet for origin. Also, the user will be able to change the choices he made initially having to reinstall the facet, by simply overriding those variable values.  

It is possible to have variables labels nationalized, allowing for the correct label to be displayed in the user interface when installing the facet. See our article on [Nationalization of labels included in project files](../pages/features-and-roles/label-localisation.md)

## Conditional File Installation

It is possible to have some of the files installed conditionally based on the values of the facet variables that the user inputs. This can help build complex facets that adapt to different situations.  

Let's say, for example, that you are building a facet for an application which extraction can come in CSV format as well as XML. You will then have a discovery file for each format, but only want to install the one relevant to the user. The simplest way to do this is to create a configuration variable that will hold the file format. Then you just need to add the condition `config.format == 'CSV'` on your CSV discovery file in the **Files conditional installation** section of the **Build** tab, and likewise for the XML format file.  

During facet installation, the proper file will be selected based on what format value the user chooses to input.  

![Condition](../add-ons/images/condition.png "Condition")

> [!warning] This functionality is only.  available as of version **2015 R2**

A facet, otherwise called an add-on, for data collection should take advantage of the silos concept to be able to iterate over any number of data files.  
This way, adding a new data file into the project, being a new file system, a new server or a new domain, will be as easy as dropping the new file in an input folder.  

To achieve this, you have to create a silo for your application, and check the option 'Iterate on files within a folder' (please refer to the corresponding documentation for more information).  

The name of the file will have to carry the information you need (for instance the server name). You can also use the filter, with naming conventions, if you have more than one file to include in the collection. See the article on [Silo concept](../silos/silos.md).  

![Silo](../add-ons/images/silo.png "Silo")

The global variable `config.siloIteratedFileShortname` can be used to retrieve the server name for the repository or application, and also for the silo name.  

Basically, your collector lines must manage everything with the name of the current file being passed on in this variable. The only information that you need from the user is the directory where the files are dropped. This is the information that needs to be added to a configuration variable. These variables are declared in a `.configvariable` type file, and should be included to the add-on. To create this file you can click New... in the audit menu:  

![New2016R3](../add-ons/images/New2016R3.png "New2016R3")

As a result, the user will only be asked for this directory location when installing the facet, and all the rest will be taken care of automatically. There will be no need to reinstall the facet when the number of files to load changes.  
