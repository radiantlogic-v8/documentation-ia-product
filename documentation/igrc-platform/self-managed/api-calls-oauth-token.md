# How to configure API calls

This guide provides information on the Access Portal API, including instructions for setting up a Client ID and Secret within your Keycloak realm for your self-managed Identity Analytics application.  

## Set up API access

To authenticate against Keycloak and access the Portal API, you'll need to update the values used in your helm chart, update your deployment and get the newly generated client secret.  

### Helm configuration  

For authentication and authorization, you will impersonate an account when calling API's. In the example below we use the account named "setup" that is present in all timeslots.  

As a reminder, it is required to use an account with access to the portal, _i.e._ an active account present in the current timeslots and reconciled with an active identity.  

To configure this, add the following values to your helm values for IDA file:  

```yaml
portal: 
  internalWebServices: 
    enabled: true 
    impersonate: setup 
    assumeRoles: technicaladmin 
    authorizedEndpoints: /ws,/get_logs 
    authorizedPort: 8081 
  api: 
    enabled: true 
    limits: 
      concurrency: 
        enabled: false 
        max: 5 
        burst: 0 
        delay: 1 
      count: 
        enabled: false 
        max: 20 
        timeWindow: 60 
      request: 
        enabled: false 
        rate: 5 
        burst: 0 
```

By default, the assumed role is "technicaladmin". You can modify the roles if needed by updating the value of the `assumeRoles` field.

Once the values of your helm updated update the deployment of the application using `helm upgrade --install ...`.  Refer to the [updating a deployment section](./index/#updating-a-deployment) to learn more. 

### Keycloak client secret

Log in to the Keycloak Admin Console, navigate to the Clients section and locate the client names `ida-portal-api`.

Retrieve the Client ID and Client Secret within the credentials tab.  

## Executing an API call

### Getting the access token

To authenticate and get an access token, you need to make a POST request to the OpenID Token endpoint of your application realm passing different parameters.

The token endpoint is:

```sh
AUTH_URL="https://<EXTERNAL_DNS>/auth/realms/<CONTEXT>/protocol/openid-connect/token"
```

Where:

- `<EXTERNAL_DNS>` is the `externalDns` parameter configured in your helm values
- `<CONTEXT>` is the `pathPrefix` configured in your helm values

The parameters to pass are:  

- `client_id`: The client ID of your application `ida-portal-api`
- `client_secret`: The client secret retrieved from Keycloak.
- `grant_type`: The type of grant being used, which is client_credentials in this case.

Please find below an example of cURL command to use:

```sh
token=$(curl \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  $AUTH_URL | jq -r '.access_token')
```

Where:  

- `$AUTH_URL`: URL of the OpenID Token endpoint
- `$CLIENT_ID`: Client ID of your application
- `$CLIENT_SECRET`: Client secret retrieved from Keycloak
- `$API_URL`: URL of the API endpoint

> Note that in this example, we are utilizing jq, a command-line tool for processing JSON data.  

### Making an API Request

Once you have the access token, you can use it to make an authenticated GET request to Identity Analytics' "Retrieve view results" endpoint with the following format:

```sh
API_URL="https://<EXTERNAL_DNS>/<context>/ws/results/<view>?<parameters>"
```

Where:

- `<EXTERNAL_DNS>` is the `externalDns` parameter configured in your helm values
- `<CONTEXT>` is the `pathPrefix` configured in your helm values

The Headers to pass are:  

- `Content-Type: application/json` the content type returned
- `Authorization: Bearer <access_token>` the authorization token obtained above

Example API request:

```sh
curl -H "Content-Type: application/json" -H "Authorization: Bearer $token" $API_URL 
```
