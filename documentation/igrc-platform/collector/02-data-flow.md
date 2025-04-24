---
title: "DataSet and data pattern"
description: DataSets and data patterns
--- 

# DataSet and data pattern

In a collector line, some components declare attributes. This is particularly the case of source components (CSV, LDIF, ...) in which a correspondence is established between the columns of the file and the attributes of the dataset which runs in memory. The modifying component also declares attributes. All these declarations are involved in the formation of the collector's data pattern. The data pattern is the inventory of all the attributes handled during the execution of the collector line. An attribute in the pattern is characterized by a name, a type (String, Number, Date, or Boolean) and a multivalued indicator. Attributes thus declared cannot change type or multivalued indicator when running.  

When running, a JavaScript function may dynamically declare a new attribute by specifying its name, type and multivalued indicator. The pattern is then completed with this new definition.  

A dataset is the element that is transmitted from one component to another by following transitions of the collector line. The dataset contains a set of attributes, where each attribute may contain one or more values as declared in the pattern (multivalued indicator). It is important to note that all the attributes declared in the collector line may not be present at all times in the dataset at runtime. Indeed, the source components only add attributes corresponding to a non-empty column in the file to the dataset. The following diagram shows the structure of a data set:

![Diagram dataset](./images/dataset-data-diagram.png "Diagram dataset")

It is important to understand this structure if you want to manipulate the dataset in a JavaScript function or a macro. There are APIs that allow you to list out each nesting level and alter the dataset or the content of a particular attribute.

## Transmitting datasets

While the collector line runs, a dataset is created by the main source and then transmitted to other components following the various transitions. There is a variable called 'dataset' which always contains the current dataset.  

In reality, the same dataset does not flow between components. Whenever a component must pass the dataset to another component through a transition, the dataset is duplicated and the next component receives a copy of the dataset. This copy becomes the current dataset available through the 'dataset' variable.  

The impact of this relates to the forks when two transitions start from the same component. For example, component A has two outgoing transitions to components B and C. When running, component A is executed and has a dataset. The dataset is duplicated and transmitted to component B. Once B has been processed, component A duplicates the dataset a second time and sends it to component C. It is important to understand in this example that component C receives dataset from component A and not from component B even if component B was run before it. If component B modifies the dataset by adding an 'attrb' attribute, component C receives a dataset that does not contain the 'attrb' attribute. For component C to receive the component B's changes in the dataset, we must review the design of the collector line to bind A to B and B to C.

## Join with a secondary source

The presence of a join in a collector line means that there are two data flows, one from the main source and the other from the secondary source. The secondary source is triggered by the join. The join is the synchronization point of two data flows that never mix.

The principle of the join is to reread the entire file from the secondary source for each primary record. This type of component is used to enrich a main record with information found in another file. Once a record goes through the join, the join component asks the secondary source to list all the secondary records. It is possible to match a main record with a specific secondary record on a join criterion such as a unique ID or an ID found in both data flows (in both files).  

To do this, the join passes the main dataset to the secondary source so that it can serve as a filter in the selection of records of the second file. In the secondary source component, a 'param' variable contains the main current dataset while the dataset variable denotes, as usual, the secondary dataset that has just been formed with the columns in the file.  

Records in the secondary source are selected by placing a filter that uses the SQL 'param' variable. In the following example, the main dataset contains the unique ID. The number is used to fetch the`email` found in a second file that contains only two columns:`userid` (the number) and `email`. At the secondary source level, the following SQL filter is set to find the record which matches the desired number (number present in the main dataset and designated by the 'param' variable):  

```sql
SELECT * FROM dataset WHERE param.unique_ID = dataset.userid  
```

In the example above, the join component asks the secondary source to list all the records. But the SQL filter only retains the records whose `userid` column in the secondary file is equal to the unique ID in the main file. Thus, only a record corresponding to the requested registration number and containing the email and `userid` is returned to the join. We note that the join is the component that calls a secondary source but it is the secondary source itself that performs the join operation by selecting the correct record.  

This operating principle offers the advantage of being generic. It applies regardless of the nature of the primary and secondary sources (file, script or other). However, in the case of a source file, the secondary file is reread for each record in the main dataset which degrades the overall performance of the collector line. It is possible to implement a cache for the join component in order to accelerate processing.  

Activating the cache means that the join component retrieves and keeps all the records from the secondary source in memory. The direct consequence is that the secondary source must, this time, provide all records without filtering because it is now the join component that performs the join operation between the two datasets. To do this, a setting in the join component allows the calculation of a key from each secondary record to compare it to a key derived from the main record. The algorithm used is as follows:  

- During the first pass in the join component
- Request the secondary source list out all the records
- For each secondary record, the join component
- Calculates a key from each secondary record
- Saves the key, records the pair in an association table (hashmap)
- During each main dataset pass, the join component
- Calculates a key from a main record
- Searches for the secondary record in the association table with the primary key  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID LIKE 'A%'  
```

Note that all references to the 'param' variable have disappeared because the secondary source is no longer joined with the unique ID of the primary dataset.  

Note that the cache is a memory cache, so it is not recommended to implement it if the number of records is too large. The memory size used is directly related to the size of the secondary source file. One way to reduce the memory size is to only cache the information useful for processing. If we take the example above with the columns `userid` and `email`, it is possible that the file read by the source contains other columns that should be ignored. In addition, if the unique IDs to be taken into account must begin with the letter 'A', there is no need to save all of the records the cache, particularly including unique IDs not starting with 'A'. To minimize the memory used in this case, you must first ensure you select only the `userid` and `email` columns in the source component and add an SQL filter which returns only records with a unique ID starting with 'A':

## Data grouping

The data grouping component is useful for gathering several values that were initially separated into several different records in a multivalued attribute. For example, an HR extraction can provide a CSV file with one line per identity. If an identity has several jobs, the identity appears on multiple lines with all the information repeated and a different job on each line. To reconstitute a single dataset with a multivalued attribute `job` from multiple CSV records, you must use the grouping component.  

The grouping component works by detecting ruptures. An expression based on the content of the dataset is set in the component in order to allow it, during the execution of the collector line, to determine when a rupture occurs. In the example with the job, the rupture happens when first name and last name change. In this case, enter the expression as follows:  

```javascript
{ dataset.first_name.get() + ' ' + dataset.last_name.get() }   
```

For each dataset arriving in the grouping component, the expression is evaluated. If the result is different from the result of the expression in the previous dataset, this means that the new dataset relates to a different identity, otherwise the dataset completes the previous dataset as it is for the same identity (same first and last name). This detection is called rupture detection.  

The algorithm used to group the attribute values is as follows:  

- For each dataset received by the component
- Calculate the rupture expression
- If no break is detected (same identity in the above example)
- Aggregation of values of this new dataset (`job` attribute in the example) in the previous dataset
- Removal the new dataset to send nothing to the following components
- Otherwise (new identity in the example)
- Emission of the previous dataset towards the following components
- Memorization of the new dataset as a starting point for the attributes aggregation

This mechanism introduces a desynchronization between the datasets received by the component and the datasets issued after grouping the `job` attribute to the following components. Indeed, while the second dataset arrives in the component group, the group outputs the first dataset to other components, and so on. With this mechanism, when the last dataset is received, the component emits the next-to-last dataset to the following components. It is only when the collector engine goes into the Flushing state that the grouping component can transmit the last dataset which was waiting for rupture detection.

## Calling a collector line

A collector line may be called from another collector line. Hiding behind this feature are two different objectives:  

- Create a data source functionally richer than the source components provided as standard.
- Run one collector line from another.

From a more technical point of view, a sub-collector line is a normal collector line with a primary source and target or filter components. In the main collector line, the sub-line can be used as a source or as a filter. Depending on the option chosen, the kinematics of dataset movement is different:

|**Type of call**|**Operation**|**Datasets returned**|
|:--|:--|:--|
|Source|The Sub-collector line replaces a source type component and behaves in exactly the same way. The sub-collector line should list the records and return them to the calling line collector in the form of datasets. The only difference is in the wealth of processes able to be performed by the sub-line because it may include as many components as necessary to shape the dataset to return to the main line.|The datasets generated by the sub-collector line are returned to the main collector line. An ending point must be defined in the sub-line to specify the component that will give its datasets to the calling line.|
|Filter|The sub-collector line is called each time a dataset is transmitted in the main collector line. However, the sub-line is not part of the main line with, for example, some filters which are linked but it is a complete line with a source type component. Overall, this means that the called collector line is not a sub-line but is an autonomous collector line in terms of data. It does not receive the dataset from the main line and it does not return a dataset. It simply triggers another collector line.|The Sub-collector line does not return any dataset. Therefore, the definition of an ending point in the sub-line is not useful.|

In general, the sub-collector lines in source mode are designed to create source component libraries with verticalized semantics. This is the best way to add repository support applications such as HR databases or business application accounts database exports to the product. The consultant can thus, through the various projects, compile a whole collection of reusable lines. When the collector line is stable, it becomes interesting to consider it as a black box by packaging it as a source component. The collector line and all its dependencies are then transformed into a file component in the library directory of the project. All the components packaged in this way appear in the palette of the source component of the collector line editor just like the standard components of the product.  

The collector lines in filter mode have a very different purpose. It is actually a question of making a main collector line which links all the lines created during a project. This allows us to launch a single line that runs all the lines in the desired order. This mode of operation is similar to a batch (in DOS mode) or a shell script (in Unix mode) that would call each collector line one by one.  
