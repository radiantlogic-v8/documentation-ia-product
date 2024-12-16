---
title: "Diagnostic"
description: "Diagnostic"
---

# Diagnostics

## Log files

All errors are written in a log file to facilitate diagnostic. Log files are written in several locations in the product.  

- They are written in the log folder of your project: `<project>\logs`. Depending on the settings used when exporting the web portal, see [Parametrization](./02-parametrization) the location of the folder can change.  
  - If the project is included in the generated WAR file it is located:  
`...\<YourTomcatDirectory>\webapps\<YourProjectName>\WEB-INF\workspace\<Project>\logs`
  - If the project is excluded from the WAR file and points to the current workspace of the studio it is located:  
`<iGRC analytics folder>\workspace\<project>\logs`
  - If you defined another location for the project, follow the specified path  
- A log file named `.log` is automatically written and always located in the following folder:    `...\<YourTomcatDirectory>\webapps\<YourProjectName>\WEB-INF\workspace\.metadata`  
- Finally, log files can be written in the web server's application folder. If you installed a personalized version of Tomcat the logs are generally located:  
`":\Program Files \Apache Software Foundation\Tomcat\logs"`.  

If you are using the provided application, Identity Analytics Application server they are then located:  
`"C:\Program Files\Identity Analytics ApplicationServer"`.  

## Extracting the log files

To extract the log files you can fetch the individual files in the above mentioned folders. To help you in this procedure simplified methods have been established.  

Once connected to the web portal you can type the following URL address to automatically download a zip file containing all logs:  
`<web portal URL >/<project>/get_logs/`.  

If the URL of the web portal is `http://localhost:8081/demo-init/portal?h=ea7a4e06`, you need to replace it with `http://localhost:8081/demo-init/get_logs/`. A window then opens asking you if you want to open of download the created zip file.  

![Zip file](./images/webportal-logs.png "Zip file")

After performing a refresh you can continue to navigate your web portal as usual.

> if the location of the tomcat log files has been customised it is possible to customise directly in the URL the path to the tomcat logs by adding `?tomcat_logs=full/path/to/logs` to the end of the URL. For example:
>
> ```txt
> https://localhost:8443/demo-Ader/get_logs/?tomcat_logs=C:/Application/apache_tomcat/apache-tomcat-8.5.13/logs
> ```

## Portal health check

A health check URL has been added to allow automatic verification of the status of the portal.
This URL is the Accessible through `/healthcheck`.

The return is a JSON payload with a 200 response code:

- `{"status":"ok"}` when all goes well  
- status is 503 (Service unavailable) with payload `{"status":"error", "message": "<msg>"}` where `<msg>` is one of
  - `no_config_injector`: The configuration has not yet been built or propagated inside the application
  - `error_in_config`: The configuration failed to complete
  - `no_project_model`: Failed to create a project model loader
  - `project_not_found`: Cannot find the project directory or no `.audit` inside it
  - `no_license`: No license file found, invalid license or not allowing the workflow module
