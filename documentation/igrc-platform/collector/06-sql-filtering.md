---
title: SQL Filtering
description: SQL filtering
---

# SQL Filtering

The data sources in a collector line offer filtering of datasets with an SQL query. SQL filtering provides a simple way to select datasets on criteria using standard syntax. This syntax can also handle multivalued attributes, called 'lists of values,' later in this chapter.

The operating principle of the SQL query is to consider the dataset that has just been created (for example, from a file) as a table containing a single row of data. The query is executed on each dataset. The query returns either the same dataset or no dataset which means that the values present do not meet the criteria expressed in the query.  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID <> 'VIP'
```

In the example above, the query is executed on each dataset created by the source. If the registration number contains the value 'VIP', the dataset is rejected because the criteria in the WHERE clause specifies that the registration number must not contain 'VIP'.

Note that it is possible to address configuration variables of the project or of the collector line by prefixing their name with config as shown in the following example for the reject variable:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID <> config.reject
```

## Query Syntax

Only SELECT queries are authorized for SQL filtering. When the query is executed, the current dataset is considered as an SQL table whose columns are the dataset attributes. This table contains only one line consisting of attribute values. The main difference with a real SQL table is that each column may contain a list of values (corresponding to a multivalued attribute of the dataset).

### Main source

In the FROM clause of the SQL query, the only allowed table name is 'dataset'. The `*` character in the projection part returns all of the attributes of the dataset. However, it is possible to return only a part of the attributes of the dataset as shown in the following example:  

```sql
SELECT unique_ID, first_name, last_name FROM dataset
```

The source, when reading the file, creates a dataset with a certain number of attributes and then the SQL query is executed and only the unique ID, first and last name attributes are retained in the dataset transmitted to the next component.  

It is also possible to create a brand new attribute in the projection area as shown in the following example with the new attribute `full_name`:  

```sql
SELECT unique_ID, first_name, last_name, concat(first_name, ' ', last_name) AS full_name FROM dataset
```

This method for adding a calculated attribute to the dataset, however, is not recommended because it bypasses the attribute declaration in the pattern. The direct consequence is that the collector editor will not suggest this name in the attribute selectors.

### Secondary source

In a source activated through a join component, two sets of data are handled:  

- `dataset`: dataset created by the secondary source
- `param`: dataset passed as a parameter by the join component

In a secondary source, the tables listed in the FROM clause may be dataset, param, or both. As before, it is also possible to restrict the attributes returned but they may come from dataset or from param as shown in the following query:  

```sql
SELECT unique_ID, first_name, last_name, param.date_arrival, param.date_departure FROM dataset
```

The attribute names without a table name (`unique_ID`, `first_name`, `last_name`) come from the table mentioned in the FROM clause (dataset) whereas the two attributes `date_arrival` and `date_departure` come explicitly from the param dataset. It is possible to retrieve the entire dataset and some attributes of param as shown in the following query:  

```sql
SELECT *, param.date_arrival, param.date_departure FROM dataset
```

Finally, if you wish to retrieve all of the attributes (dataset and param), both of the following syntaxes work:  

```sql
SELECT * FROM dataset, param
SELECT *, param.* FROM dataset
```

## Operators  

Operators allow you to make comparisons (equal, less than, greater than, ...) or to combine operations through logical operators (and, or, ...).  

Operators work on simple values as well as on lists of values. To obtain a list of values, the attribute must be declared as being multivalued in the pattern and the input file must contain multiple values for a single CSV column or a single LDIF attribute. The result of the comparison depends on the operator used. Here is the explanation for the three main operators with an example of syntax:

- '=' Operator: It is a strict equality operator, which can compare two simple values or two lists. For the operator to return true, the two operands must possess the same number of values, and the values must be identical. If the objective is to compare a value and a list, you must use the IN operator or the LIKE operator. The following example shows the comparison of two multivalued attributes:  
  
```sql
SELECT * FROM dataset WHERE dataset.unique_ID = dataset.userid
```

- `IN` Operator: The IN operator is useful to verify whether a value is in a list. The following example shows the syntax of the IN operator to test whether one of the values of the unique ID attribute is equal to ‘EXT0001’:  

```sql
SELECT * FROM dataset WHERE 'EXT0001' IN (dataset.unique_ID)
```  

> Note that the left operand of the IN operator may also be a list. In this case, the operation performed is an inclusion test. The result is true if all the values of the left operand are found in the list of values of the right operand. The syntax is as follows:
>
> ```sql
> SELECT * FROM dataset WHERE dataset.userid IN (dataset.unique_ID)
> ```

- `LIKE` Operator: The `LIKE` operator allows you to use wildcards like `%` or `_`. If the left operand is a list, the `LIKE` operator returns true if one of the values of the list respects the regular expression in the right operand. The syntax is:  
  
```sql
SELECT * FROM dataset WHERE dataset.unique_ID LIKE 'EXT%'
```

Important: All the operators are case-sensitive. If the unique ID contains 'EXT0001', none of the following queries returns the record in question:

```sql
SELECT * FROM dataset WHERE dataset.unique_ID = 'ext0001'
SELECT * FROM dataset WHERE dataset.unique_ID LIKE 'ext%'
SELECT * FROM dataset WHERE 'ext0001' in (dataset.unique_ID)
```

To make the query non-case-sensitive in the previous example, you must use the upper or lower functions to convert the unique ID:

```sql
SELECT * FROM dataset WHERE lower(dataset.unique_ID) = 'ext0001'
SELECT * FROM dataset WHERE lower(dataset.unique_ID) LIKE 'ext%'
SELECT * FROM dataset WHERE 'ext0001' in (lower(dataset.unique_ID))
```

Note that most of the functions (such as lower, upper, trim,...) may be applied to single-valued or multivalued attributes.

### Arithmetic operator

The list of supported arithmetic operators is:  

- `+` for addition
- `-` for subtraction
- `*` for multiplication
- `/` for division

These operators only work on numerical operands. Lists of values are not supported. To ensure the order of operations, it is possible to use parentheses in the expression. Here are some examples using these operators:

```sql
SELECT * FROM dataset WHERE len(dataset.unique_ID) - 1 < 3
SELECT * FROM dataset WHERE 2 + (dataset.counter / 10) > 5
```

### Comparison operator

The comparison operators are:  

- `=`: true if both operands are equal
- `<>` or `!=`: true if both operands are different
- `<`: true if the first operand is strictly less than the second operand
- `<=`: true if the first operand is less than or equal to the second operand
- `>`: true if the first operand is strictly greater than the second operand
- `>=`: true if the first operand is greater than or equal to the second operand  

The first two operators (`=` and `<>`) operate on values or lists of values. These strict comparisons return true only if the values of two operands are identical (for the `=` operator) or all different (for the `<>` operator).  

The other operators do not work on lists of values. Both operands must be simple values. If the comparison involves two values of different types, the second operand is automatically converted to the type of the first operand during the comparison. Here are some examples using these operators:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID = 'INT0001'
SELECT * FROM dataset WHERE dataset.date_departure < now()
```

### Logical operator

The supported logical operators are:  

- `AND`: true if both operands are true
- `OR`: true if one of the two operands is true
- `NOT`: true if the operand is false  

These operators only work on Boolean operands. Lists of values are not supported. These operators all return a Boolean result. Here are some examples using these operators:  

```sql
SELECT * FROM dataset WHERE len(dataset.unique_ID) > 3 AND dataset.unique_ID LIKE 'I%'
SELECT * FROM dataset WHERE NOT (upper(dataset.unique_ID) LIKE 'EXT%' OR dataset.unique_ID= 'VIP')
```

### IS NULL operator

Tests whether a value is null.  

**Syntax**:  

- `<value_or_list> IS NULL`

**Result**:

- true if `value_or_list` is null, false otherwise. If `value_or_list` is a list, the result is true if the list is empty or if the list only contains null values.  

**Operand**:  

- `value_or_list`: String or Number or Boolean or Date or List The operand may be a simple value or a list of values.

**Example calls**:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID IS NULL
SELECT * FROM dataset WHERE dataset.unique_ID IS NOT NULL and trim(upper(dataset.unique_ID)) = 'EXT0001'
```

### LIKE operator

Tests whether a value respects a regular expression.  

**Syntax**:  

- `<left_value_or_list>``LIKE <right_value_or_list> [ESCAPE <escape_value>]`  

**Result**:

- `true` if the `left_value_or_list` respects the regular expression present in `right_value_or_list`, otherwise `false`. If `left_value_or_list` is a list, the result is true if at least one value in the list respects this regular expression in `right_value_or_list`. If `right_value_or_list` is also a list, the result is true if at least one value in the `left_value_or_list` respects one of the regular expressions present in `right_value_or_list`.  

**Operand**:  

- `left_value_or_list`: String or Number or Boolean or Date or List Single value or list of values which must respect the regular expression. If the operand is a list of values, the result is true if at least one value respects the regular expression.
- `right_value_or_list`: String or Number or Boolean or Date or List Regular expression using wildcards `_`, `%` and `[]`. If the operand is a list of regular expressions, the result is true if at least one of the values of the `left_value_or_list` operand respects one of the regular expressions of the list. The meaning of the wildcards is as follows:
  - `_` character: corresponds to any single character. For example, the value `'EXT0001'` respects the regular expressions `'EX_0001'` and `'EXT___1'`
  - `%` character: matches any sequence of characters. For example, the value `'EXT0001'` respects the regular expressions `'EXT%'`, `'EXT%1'`, `'EXT0001%'`, `'%000%'` and `'EXT000%1'`
  - `[]` characters: correspond to a list of characters. For example, the value `'EXT0001'` respects the regular expressions `'[AEIOU]XT0001'`, `'EXT000[0123456789]'`. Warning, syntax designating a range of characters, such as `'[0-9]'` is not supported.  

It is of course possible to combine different wildcards in the same regular expression. For example, the value `'EXT0001'` respects the regular expressions `'_XT000[0123456789]' and 'EXT___1%'`  

- `escape_value`: String String containing the escape character if one of the wildcards of the regular expression must be interpreted as a simple character. For example, if the `left_value_or_list` operand contains the value `'jean_pierre'` and you need to test for the presence of the `'_'` character, you must indicate to the `LIKE` operator that it should consider the `'_'` character as a simple character and not as a wildcard. For this, the `'_'` character is preceded by an escape character (like `'\'`) which you must mark as such to the `LIKE` operator with the keyword `ESCAPE` followed by the escape character.  

**Example calls**:  

```sql
SELECT * FROM dataset WHERE lower(dataset.unique_ID) LIKE 'ext%'
SELECT * FROM dataset WHERE dataset.unique_ID LIKE '\_' ESCAPE '\'
SELECT * FROM dataset WHERE dataset.unique_ID NOT LIKE 'EXT000[0123456789]'
```

### BETWEEN operator

Test whether a value is in a range.  

**Syntax**:

- `<value>` BETWEEN `<low_limit>` AND `<high_limit>`  

**Result**:  

- true if the value is greater than or equal to `low_limit` and less than or equal to `high_limit`, false otherwise. The BETWEEN operator does not support lists of values in any of the operands. If the data type is different between one value and one of the limits, an implicit conversion of the limit is performed in order to perform the comparison.

**Operands**:  

- `value: String` or `Number` or `Boolean` or `Date`. The value to be compared.
- `low_limit: String` or `Number` or `Boolean` or `Date`. The lowest authorized limit for the value. If this value is not the same type as the value, an implicit conversion of the `low_limit` is performed before the comparison.
- `high_limit: String` or `Number` or `Boolean` or `Date`. The highest authorized limit for the value. If this value is not of the same type as the value, an implicit conversion of the `high_limit` is performed before the comparison.

**Example calls**:  

```sql
SELECT * FROM dataset WHERE dataset.arrival BETWEEN '20080101000000' AND now()
SELECT * FROM dataset WHERE len(dataset.unique_ID) NOT BETWEEN 6 AND 10
```

### In operator

Tests whether a value is present in a list of values.  

**Syntax**:  

- `<value_or_list> IN (<value_set>)`

**Result**:  

- `true` if the value of `value_or_list` is present in `value_set`, false otherwise. If `value_or_list` is a list, the Result is `true` if all the values in the list are present in `value_set`.  

**Operands**:  

- `value_or_list`: String or Number or Boolean or Date or List. Single value or list of values that must be present in `value_set`. If the operand is a list of values, the Result is true if all of the values are present in `value_set`.

- `value_set`: String or Number or Boolean or Date or List. List of values separated by commas. Each value may be a single value or a list of values.

**Example calls**:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID IN ('EXT0001', 'EXT0002', 'EXT0003')
SELECT * FROM dataset WHERE dataset.unique_ID NOT IN ('EXT0001', dataset.userid)
SELECT * FROM dataset WHERE 'EXT0001 IN (dataset.userid)
```

## Functions

In some cases, filtering records requires a calculation, conversion or data transformation. The functions in this chapter are mainly used in the where clause. They may be combined in order to combine several operations. The following example shows the transformation of a string to uppercase and the removal of spaces from beginning and end:  

```sql
SELECT * FROM dataset WHERE trim(upper(dataset.unique_ID)) = 'EXT0001'
```  

An important point to watch is the processing of null values. In the example above, if the unique ID may be null (not given in the input file), then it becomes imperative to test the nullity in the where clause before calling a function, as shown in the following example:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID is not null and trim(upper(dataset. unique_ID)) = 'EXT0001'
```  

Without the test of nullity, the line collector stops running with an exception caused by calling a function on a null value.  

Also note that most functions treat single values as well as lists. If a unique ID is declared as multivalued, the previous query does not work because of the strict equality comparison. If the unique ID is a list of three values, the equality operator returns false because it would have to have two list type operands with the same values to return true. To pass the test successfully if the value '`EXT0001`' is part of the list, the request must be transformed as follows:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID is not null and 'EXT0001' in (trim(upper(dataset.unique_ID)))
```  

In this example, if the unique ID is a list of three values, they are transformed to uppercase by the upper function which returns the list of three values, then the trim function removes the spaces from the three values and returns the list of three values, and finally the 'in' operator searches for the '`EXT0001`' value.  

The LIKE operator also works on a list of values. Another way to formulate the query to obtain the same Result is as follows:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID is not null and trim(upper(dataset.unique_ID)) LIKE 'EXT0001'
```  

If the desired value is any unique ID starting with EXT, the previous query may be transformed as follows to use wildcards:  

```sql
SELECT * FROM dataset WHERE dataset.unique_ID is not null and trim(upper(dataset.unique_ID)) LIKE 'EXT%'
```  

### Ascii function

Returns the Unicode code of the first character of the string passed as parameter.  

**Signature**:  

- `ascii(value): Number`  

**Return value**:  

- a string consisting of only one character whose code is the value  

**Parameters**:  

- value: String. String whose first character must be transformed into Unicode.  

**Example call**:  

```sql
SELECT * FROM dataset WHERE ascii('A') = 65
SELECT * FROM dataset WHERE left(dataset.unique_ID, 1) = ascii('E')
```

### Char function

Returns a string consisting of only one character whose Unicode code is passed as a parameter.  

**Signature**:  

- `char(value)`: String

**Other signature**:  

- `chr(value)`: String

**Return value**:  

- a string consisting of only one character whose code is the value

**Parameters**:  

- value: Number. Numerical value corresponding to the Unicode code of the character to be transformed into a string.

**Example call**:  

```sql
SELECT * FROM dataset WHERE char(65) = 'A'
SELECT * FROM dataset WHERE left(dataset.unique_ID, 1) = char(69)
```

### Concat function

Concatenates one or more strings to another string or to a list.  

**Signature**:  

- `concat(value_or_list, str[, ...])`: String or List

**Return value**:  

- The string with the concatenated values if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned, after the concat function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String to be modified. If the parameter is a list of strings, all the values of the list undergo the application of the concat function.

- `str`: String (varying number of parameters). String(s) to be concatenated.

**Example call**:  

```sql
SELECT * FROM dataset WHERE concat(dataset.unique_ID, 'ab', 'cd') LIKE '%abcd'
```

### Format function

Converts a date to a string, respecting the format given as a parameter.

**Signature**:

- `format(value, pattern): String`

**Return value**:

- a string containing the date in the requested format

**Parameters**:

- `value: Date.` Date to be transformed into a string.
- `pattern: String.` String of characters giving the conversion format. The format respects the specification of the Java java.text.SimpleDateFormat class. The most frequently used characters are:
  - y: year
  - M: month
  - d: day of the month
  - H: hours
  - m: minutes
  - s: seconds

Examples of formats:  

```text
'dd/MM/yy HH:mm:ss' gives '23/05/11 15:40:12'
'dd MMM yyyy' gives '23 May 2011'
```

**Example call**:  

```sql
SELECT * FROM dataset WHERE format(dataset.arrival, 'yyyy') = '2011'
```

### Insert function

Inserts a string into another string or into a list.

**Signature**:

- `insert(value_or_list, start, len, str): String or List`

**Return value**:

- The string completed with the string to be inserted if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the insert function has been applied to each value.

**Parameters**:

- `value_or_list: String` or `List`. String to be completed. If the parameter is a list of strings, all the values of the list undergo the application of the insert function.
- `start: Number.` Starting index of the insertion in the `value_or_list` string. Index 1 corresponds to the first character. If this value is greater than or equal to the length of the `value_or_list` string, the two strings are concatenated.
- `len: Number.` Number of characters to replace in the `value_or_list` string. The value 0 allows the insertion of the string. A value greater than 0 performs a replacement in the `value_or_list` string.
- `str: String.` String to be inserted.

**Example call**:  

```sql
SELECT * FROM dataset WHERE insert(dataset.unique_ID, 4, 0, 'xx') LIKE 'intxx%'
```

### Instr function

Looks for the index of a certain occurrence of the specified value in a string.  

**Signature**:  

- `instr(full, search[, start[, repeat]])`: Number

**Return value**:  

- The index of the occurrence of the specified value or 0 if it is not found

**Parameters**:  

- `full`: String. String in which the search is carried out.
- `search`: String. String of characters to search for.
- `start`: Number (optional). Starting index of the search. Index 1 corresponds to the first character.
- `repeat`: Number (optional). Number of the occurrence. Numbering starts at 1 to obtain the first occurrence.

**Example call**:  

```sql
SELECT * FROM dataset WHERE instr(dataset.unique_ID, 'xt') = 2
```

### Left function

Extracts a certain number of characters from a string or list of strings starting with the first position.  

**Signature**:  

- `left(value_or_list, len)`: String or List

**Return value**:  

- A string containing the number of characters requested starting from the first position if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the left function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String, of which a part is extracted. If the parameter is a list of strings, all the values of the list undergo the left function.
- len: Number. A whole number between 0 and the length of the string.

**Example call**:  

```sql
SELECT * FROM dataset WHERE left(dataset.unique_ID, 3) = 'Ext'
```

### Len function

Returns the number of characters in a string.  

**Signature**:  

- `len(value)`: Number

**Other signature**:  

- `character_length(value)`: Number

**Other signature**:  

- `char_length(value)`: Number

**Return value**:  

- The number of characters in the string

**Parameters**:  

- `value`: String. String whose size is to be calculated.

**Example call**:  

```sql
SELECT * FROM dataset WHERE len(dataset.unique_ID) > 3
```

### Listget function

Extracts an element from a list of values.  

**Signature**:  

- `listget(value_or_list, index)`: String or Number or Boolean or Date

**Return value**:  

- The value in the list at the specified index. The type of the return value is the same as the type of the list elements.

**Parameters**:  

- `value_or_list`: String or Number or Boolean or Date or List. If the parameter is a list of values, the value present at the specified index is returned. If the value is a single value, it is returned if the index passed as a second parameter is 1.
- `index`: Number. Index of the desired value in the list. The first value is located at index 1.

**Example call**:  

```sql
SELECT * FROM dataset WHERE listget(dataset.unique_ID, 1) = 'EXT0001'
```

### Listgetstring function

Extracts an element from a list of values and converts it to a string.  

**Signature**:  

- `listgetstring(value_or_list, index)`: String

**Return value**:  

- The value in the list at the specified index, converted into a string.

**Parameters**:  

- `value_or_list:` String or Number or Boolean or Date or List. If the parameter is a list of values, the value at the specified index is returned after string conversion. If the value is a single value, it is converted into a string and returned if the index passed as a second parameter is 1.

- `index:` Number. Index of the desired value in the list. The first value is located at index 1.

**Example call**:  

```sql
SELECT * FROM dataset WHERE listgetstring(dataset.unique_ID, 1) = 'EXT0001'
```

### Listsize function

Returns the number of elements in a list of values.  

**Signature**:  

- `listsize(value_or_list)`: Number

**Return value**:  

- The number of elements if the `value_or_list parameter` is a list. If the `value_or_list` parameter is not a list, the function returns 1 if the value is not null or 0 if the value is null.

**Parameters**:  

- `value_or_list`: String or Number or Boolean or Date or List. Parameter whose size is to be calculated. The function is especially useful if the parameter is a list of values (attribute declared as multivalued) but it also works with single or null values.

**Example call**:  

```sql
SELECT * FROM dataset WHERE listsize(dataset.unique_ID) = 2
```

### Lower function

Converts a string or a list of strings to lowercase.  

**Signature**:  

- `lower(value_or_list)`: String or List

**Other signature**:  

- `lcase(value_or_list)`: String or List

**Return value**:  

- The string in lowercase if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned with all values converted to lowercase

**Parameters**:  

- `value_or_list`: String or List. String to be converted to lowercase. If the parameter is a list of strings, all the values of the list are converted to lowercase.

**Example call**:  

```sql
SELECT * FROM dataset WHERE lower(dataset.unique_ID) LIKE 'ext%'
```

### Lpad function

Adds a repetition of characters to the beginning of a string or list of strings.  

**Signature**:  

- `lpad(value_or_list, num[, pattern])`: String or List

**Return value**:  

- string complemented with a repetition of characters at the beginning if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned, after the `lpad` function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String to be completed at the beginning. If the parameter is a list of strings, all the values of the list undergo the `lpad` function.
- `num`: Number. Number of repetitions of the pattern string or of a space if the pattern is not specified.
- `pattern`: String (optional). String to be repeated in the beginning. If the parameter is omitted, the repeated pattern is the space character.  

**Example call**:  

```sql
SELECT * FROM dataset WHERE lpad(dataset.unique_ID, 3, 'Z') LIKE 'ZZZint%'
```

### Ltrim function

Returns a string or a list of string without leading spaces.  

**Signature**:  

- `ltrim(value_or_list)`: String or List

**Return value**:  

- The string without leading spaces if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the `ltrim` function is applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String from which leading spaces must be removed. If the parameter is a list of strings, all the values of the list undergo the `ltrim` function.

**Example call**:  

```sql
SELECT * FROM dataset WHERE ltrim(dataset.unique_ID) LIKE 'int%'
```

### Now function

Returns the current date.  

**Signature**:  

- `now()`: Date

**Other signature**:  

- `localtimestamp()`: Date

**Return value**:  

- The current date

**Parameters**:  

- none

**Example call**:  

```sql
SELECT * FROM dataset WHERE dataset.departure is null or dataset.departure > now()
```

### Number function

Converts Boolean, date or string data into a number.  

**Signature**:  

- `number(value_or_list)`: Number or List

**Return value**:  

- A number representing the converted data if the `value_or_list` parameter is not a list. If the `value_or_list` parameter is a list, a new list is returned after the number function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or Number or Boolean or Date or List. Data of any type to be converted to a number. If the parameter is a list, all the values of the list undergo the number function.

**Example call**:  

```sql
SELECT * FROM dataset WHERE number('123') = 123
```

### Position function

Looks for the index of the first occurrence of the specified value within a string.  

**Signature**:  

- `position(search, full[, start])`: Number

**Other signature**:  

- `locate(search, full[, start])`: Number

**Return value**:  

- The index of the first occurrence of the specified value, or 0 if it is not found

**Parameters**:  

- `search`: String. String of characters to look for.
- `full`: String. String of characters in which to look.
- `start`: Number (optional). Starting index of the search. Index 1 corresponds to the first character.

**Example call**:  

```sql
SELECT * FROM dataset WHERE position('xt', dataset.unique_ID) = 2
```

### Repeat function

Creates a string by repeating another string several times.  

**Signature**:  

- `repeat(value, num)`: String

**Return value**:  

- The string constituted by a repetition of the value parameter

**Parameters**:  

- `value`: String. String to be repeated several times.
- `num`: Number. Number of repetition of the value string.

**Example call**:  

```sql
SELECT * FROM dataset WHERE repeat(dataset.unique_ID, 3) = 'int123int123int123'
```

### Replace function

Replaces all occurrences of a string within another string or in a list.  

**Signature**:  

- `replace(value_or_list, search, str)`: String or List

**Return value**:  

- The string with the values replaced if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the replace function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String to be modified. If the parameter is a list of strings, all the values of the list under the replace function.
- `search`: String. String to search for.
- `str`: String. Replacement string.

**Example call**:  

```sql
SELECT * FROM dataset WHERE replace(dataset.unique_ID, 'int', 'xx') LIKE 'xx%'
```

### Right function

Extracts a certain number of characters from a string or a list of strings starting from the last position.  

**Signature**:  

- `right(value_or_list, len)`: String or List

**Return value**:  

- A string containing the number of characters requested starting from the last position if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the right function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String from which a part is extracted. If the parameter is a list of strings, all the values of the list undergo the right function.
- `len`: Number. A whole number between 0 and the length of the chain.

**Example call**:  

```sql
SELECT * FROM dataset WHERE right(dataset.unique_ID, 2) = '00'
```

### Rpad function

Adds a repetition of characters at the end of a string or a list of strings.  

**Signature**:  

- `rpad(value_or_list, num[, pattern])`: String

**Return value**:  

- The string completed with a repetition of characters at the end if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the `rpad` function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String to be completed at the end. If the parameter is a list of strings, all the values of the list undergo the rpad function.
- `num`: Number. Number of repetitions of the pattern string or of a space if the pattern is not specified.
- `value`: String (optional). String to be repeated at the beginning. If this parameter is omitted, the repeated pattern is the space character.

**Example call**:  

```sql
SELECT * FROM dataset WHERE rpad(dataset.unique_ID, 3, 'Z') LIKE '%00ZZZ'
```

### Rtrim function

Returns a string or a list of strings without trailing spaces.  

**Signature**:  

- `rtrim(value_or_list)`: String or List

**Return value**:  

- The string without trailing spaces if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the `rtrim` function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String from which trailing spaces must be removed. If the parameter is a list of strings, all the values of the list undergo the `rtrim` function.

**Example call**:  

```sql
SELECT * FROM dataset WHERE rtrim(dataset.unique_ID) LIKE '%00'
```

### Space function

Create a string consisting of spaces.  

**Signature**:  

- `space(num)`: String

**Return value**:  

- The string consisting of spaces

**Parameters**:  

- `num`: Number. Number of spaces in the string.

**Example call**:  

```sql
SELECT * FROM dataset WHERE space(3) = ' '
```

### String function

Converts numerical, Boolean or date data into a string.  

**Signature**:  

- `string(value_or_list)`: String or List

**Return value**:  

- A string containing the converted data if the `value_or_list` parameter is not a list. If the `value_or_list` parameter is a list, a new list is returned after the string function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or Number or Boolean or Date or List. Data of any type to be converted into a string. If the parameter is a list, the string function is applied to all the values of the list.

**Example call**:  

```sql
SELECT * FROM dataset WHERE string(123) = '123'
```

### Substring function

Extracts a certain number of characters from a string or from a list of strings starting from a certain position.  

**Signature**:  

- `substring(value_or_list, start[, len])`: String or List

**Other signatures**:  

- `mid(value_or_list, start[, len])`: String or List
- `substr(value_or_list, start[, len])`: String or List

**Return value**:  

- A string containing the requested number of characters starting from the start position if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the substring function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String from which a part must be extracted. If the parameter is a list of strings, the substring function is applied to all the values in the list.
- `start`: Number. A whole number between 1 and the string length.
- `len`: Number (optional). A whole number between 0 and the string length. If this value is not provided, all the characters from the start position and up until the end of the string are returned.

**Example call**:  

```sql
SELECT * FROM dataset WHERE substring(dataset.unique_ID, 1, 2) = 'xt'
```  

> The signature of the substring function is very different from the signature of the substring method of JavaScript or of Java. The last parameter is the length of the substring, whereas in JavaScript or Java, the last parameter is the index of the end of the substring. In addition, the position of the first character in the string is 1 in SQL, unlike Java or JavaScript where numbering starts at 0.  

### Trim function

Returns a string or a list of strings without leading or trailing spaces.  

**Signature**:  

- `trim(value_or_list)`: String or List

**Return value**:  

- The string without leading or trailing spaces if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned after the trim function has been applied to each value.

**Parameters**:  

- `value_or_list`: String or List. String from which leading and trailing spaces are to be removed. If the parameter is a list of strings, the trim function is applied to all the values of the list.

**Example call**:  

```sql
SELECT * FROM dataset WHERE trim(dataset.unique_ID) LIKE 'int%00'
```

### Upper function

Converts a string or list of strings to uppercase.  

**Signature**:  

- `upper(value_or_list)`: String or List

**Other signature**:  

- `ucase(value_or_list)`: String or List

**Return value**:  

- The string in uppercase if the `value_or_list` parameter is a string. If the `value_or_list` parameter is a list of strings, a new list is returned with all values converted to uppercase

**Parameters**:  

- `value_or_list`: String or List. String to be converted to uppercase. If the parameter is a list of strings, all the values of the list are converted to uppercase.

**Example call**:  

```sql
SELECT * FROM dataset WHERE upper(dataset.unique_ID) LIKE 'INT%'
```

## Javascript calls

The SQL query may also call a JavaScript function in the script associated with the collector line. It is possible to pass parameters to the function. Here is an example call with a parameter:  

```sql
SELECT * FROM dataset WHERE checkInternal(upper(dataset.unique_ID)) = 'internal'
```  

The associated function returns the 'internal' string if the registration number is that of an in-house person:  

```javascript
function checkInternal(userId) {
  if ((userId == null) || (userId == '')) {
  return 'external';
  }
  var prefix = userId.substring(0, 3).toUpperCase();
  if ((prefix == 'VIP') || (prefix == 'EXT')) {
  return 'external';
  }
  return 'internal';
}
```

> The current record being filtered is accessible through the predefined variable dataset.
